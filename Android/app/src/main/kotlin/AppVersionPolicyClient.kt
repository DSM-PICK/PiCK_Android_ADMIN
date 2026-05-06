package pi.ckadmin

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors
import kotlin.math.max

internal data class AndroidUpdatePolicy(
    val latestVersionCode: Int,
    val minSupportedVersionCode: Int,
    val latestVersionName: String?,
    val forceMessage: String,
    val optionalMessage: String,
    val playStoreUrl: String
)

internal sealed interface AndroidUpdateDecision {
    data object None : AndroidUpdateDecision
    data class Optional(val policy: AndroidUpdatePolicy) : AndroidUpdateDecision
    data class Force(val policy: AndroidUpdatePolicy) : AndroidUpdateDecision
}

internal class AppVersionPolicyClient(
    private val context: Context
) {
    companion object {
        const val EXTRA_POLICY_JSON = "pick_update_policy_json"
        private const val META_POLICY_JSON = "pi.ckadmin.APP_UPDATE_POLICY_JSON"
        private const val META_POLICY_URL = "pi.ckadmin.APP_UPDATE_POLICY_URL"
        private const val META_PLAY_STORE_URL = "pi.ckadmin.PLAY_STORE_URL"
        private const val DEFAULT_FORCE_MESSAGE = "새 버전이 출시되었습니다. 업데이트 후 이용해주세요."
        private const val DEFAULT_OPTIONAL_MESSAGE = "새 버전이 출시되었습니다. 업데이트하시겠습니까?"
        private const val CONNECTION_TIMEOUT_MS = 5_000
        private val ioExecutor = Executors.newSingleThreadExecutor { runnable ->
            Thread(runnable, "pick-admin-update-policy").apply {
                isDaemon = true
            }
        }
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    fun resolveUpdateDecision(
        launchIntent: Intent?,
        callback: (AndroidUpdateDecision) -> Unit
    ) {
        val inlineJson = launchIntent?.getStringExtra(EXTRA_POLICY_JSON)?.takeUnless { it.isBlank() }
            ?: manifestMetadataValue(META_POLICY_JSON)?.takeUnless { it.isBlank() }

        if (inlineJson != null) {
            val decision = runCatching {
                parsePolicy(inlineJson)?.let(::evaluatePolicy) ?: AndroidUpdateDecision.None
            }.getOrElse { error ->
                logger.warning("failed to parse inline update policy: ${error.message}")
                AndroidUpdateDecision.None
            }
            callback(decision)
            return
        }

        val policyUrl = manifestMetadataValue(META_POLICY_URL)?.takeUnless { it.isBlank() }
        if (policyUrl == null) {
            callback(AndroidUpdateDecision.None)
            return
        }

        ioExecutor.execute {
            val decision = runCatching {
                val payload = fetchPolicyJson(policyUrl)
                parsePolicy(payload)?.let(::evaluatePolicy) ?: AndroidUpdateDecision.None
            }.getOrElse { error ->
                logger.warning("failed to resolve update policy: ${error.message}")
                AndroidUpdateDecision.None
            }

            mainHandler.post {
                callback(decision)
            }
        }
    }

    private fun evaluatePolicy(policy: AndroidUpdatePolicy): AndroidUpdateDecision {
        val currentVersionCode = currentVersionCode()
        logger.info(
            "app update policy loaded: current=${currentVersionCode}, min=${policy.minSupportedVersionCode}, latest=${policy.latestVersionCode}"
        )

        return when {
            currentVersionCode < policy.minSupportedVersionCode -> AndroidUpdateDecision.Force(policy)
            currentVersionCode < policy.latestVersionCode -> AndroidUpdateDecision.Optional(policy)
            else -> AndroidUpdateDecision.None
        }
    }

    private fun parsePolicy(payload: String): AndroidUpdatePolicy? {
        val root = JSONObject(payload)
        val androidPolicy = if (root.has("android")) root.optJSONObject("android") ?: root else root

        val minSupportedVersionCode = androidPolicy.optInt("minSupportedVersionCode", -1)
        val latestVersionCode = androidPolicy.optInt("latestVersionCode", -1)
        if (minSupportedVersionCode < 0 && latestVersionCode < 0) {
            return null
        }

        val normalizedLatestVersionCode = max(latestVersionCode, minSupportedVersionCode)
        val normalizedMinSupportedVersionCode = if (minSupportedVersionCode >= 0) {
            minSupportedVersionCode
        } else {
            normalizedLatestVersionCode
        }

        return AndroidUpdatePolicy(
            latestVersionCode = normalizedLatestVersionCode,
            minSupportedVersionCode = normalizedMinSupportedVersionCode,
            latestVersionName = androidPolicy.optString("latestVersionName").takeUnless { it.isBlank() },
            forceMessage = androidPolicy.optString("forceMessage")
                .takeUnless { it.isBlank() }
                ?: DEFAULT_FORCE_MESSAGE,
            optionalMessage = androidPolicy.optString("optionalMessage")
                .takeUnless { it.isBlank() }
                ?: DEFAULT_OPTIONAL_MESSAGE,
            playStoreUrl = androidPolicy.optString("playStoreUrl")
                .takeUnless { it.isBlank() }
                ?: manifestMetadataValue(META_PLAY_STORE_URL)
                ?.takeUnless { it.isBlank() }
                ?: defaultPlayStoreUrl()
        )
    }

    private fun fetchPolicyJson(policyUrl: String): String {
        val connection = URL(policyUrl).openConnection() as HttpURLConnection
        return try {
            connection.requestMethod = "GET"
            connection.connectTimeout = CONNECTION_TIMEOUT_MS
            connection.readTimeout = CONNECTION_TIMEOUT_MS
            connection.useCaches = false
            connection.instanceFollowRedirects = true

            val responseCode = connection.responseCode
            if (responseCode !in 200..299) {
                throw IllegalStateException("policy request failed with HTTP ${responseCode}")
            }

            connection.inputStream.bufferedReader().use { reader ->
                reader.readText()
            }
        } finally {
            connection.disconnect()
        }
    }

    private fun manifestMetadataValue(key: String): String? =
        runCatching {
            val applicationInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.packageManager.getApplicationInfo(
                    context.packageName,
                    PackageManager.ApplicationInfoFlags.of(PackageManager.GET_META_DATA.toLong())
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)
            }

            applicationInfo.metaData?.get(key)?.toString()
        }.getOrNull()

    private fun currentVersionCode(): Int {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.packageManager.getPackageInfo(
                context.packageName,
                PackageManager.PackageInfoFlags.of(0)
            )
        } else {
            @Suppress("DEPRECATION")
            context.packageManager.getPackageInfo(context.packageName, 0)
        }

        return packageInfo.safeVersionCode()
    }

    private fun PackageInfo.safeVersionCode(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            longVersionCode.toInt()
        } else {
            @Suppress("DEPRECATION")
            versionCode
        }

    private fun defaultPlayStoreUrl(): String =
        "https://play.google.com/store/apps/details?id=${context.packageName}"
}
