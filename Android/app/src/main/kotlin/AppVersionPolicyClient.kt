package pi.ckadmin

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings

private const val KEY_LATEST_VERSION_CODE = "android_latest_version_code"
private const val KEY_MIN_SUPPORTED_VERSION_CODE = "android_min_supported_version_code"
private const val KEY_LATEST_VERSION_NAME = "android_latest_version_name"
private const val KEY_FORCE_MESSAGE = "android_force_update_message"
private const val KEY_OPTIONAL_MESSAGE = "android_optional_update_message"
private const val KEY_PLAY_STORE_URL = "android_play_store_url"

private const val DEFAULT_FORCE_MESSAGE = "새 버전이 출시되었습니다. 업데이트 후 이용해주세요."
private const val DEFAULT_OPTIONAL_MESSAGE = "새 버전이 출시되었습니다. 업데이트하시겠습니까?"

data class AppVersionPolicy(
    val latestVersionCode: Long,
    val minSupportedVersionCode: Long,
    val latestVersionName: String,
    val forceMessage: String,
    val optionalMessage: String,
    val playStoreUrl: String,
) {
    fun requirementFor(currentVersionCode: Long): AppUpdateRequirement {
        return when {
            minSupportedVersionCode > currentVersionCode -> AppUpdateRequirement.FORCED
            latestVersionCode > currentVersionCode -> AppUpdateRequirement.OPTIONAL
            else -> AppUpdateRequirement.NONE
        }
    }
}

enum class AppUpdateRequirement {
    NONE,
    OPTIONAL,
    FORCED,
}

class AppVersionPolicyClient(private val context: Context) {
    private val remoteConfig: FirebaseRemoteConfig = FirebaseRemoteConfig.getInstance()

    init {
        remoteConfig.setConfigSettingsAsync(
            FirebaseRemoteConfigSettings.Builder()
                .setMinimumFetchIntervalInSeconds(60 * 60)
                .build()
        )
        remoteConfig.setDefaultsAsync(
            mapOf(
                KEY_LATEST_VERSION_CODE to 0L,
                KEY_MIN_SUPPORTED_VERSION_CODE to 0L,
                KEY_LATEST_VERSION_NAME to "",
                KEY_FORCE_MESSAGE to DEFAULT_FORCE_MESSAGE,
                KEY_OPTIONAL_MESSAGE to DEFAULT_OPTIONAL_MESSAGE,
                KEY_PLAY_STORE_URL to defaultPlayStoreUrl(),
            )
        )
    }

    fun fetchPolicy(onComplete: (AppVersionPolicy?) -> Unit) {
        remoteConfig.fetchAndActivate()
            .addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    logger.warning("Remote config update policy fetch failed: ${task.exception}")
                    onComplete(null)
                    return@addOnCompleteListener
                }

                onComplete(currentPolicy())
            }
    }

    fun currentVersionCode(): Long {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.packageManager.getPackageInfo(
                context.packageName,
                PackageManager.PackageInfoFlags.of(0),
            )
        } else {
            @Suppress("DEPRECATION")
            context.packageManager.getPackageInfo(context.packageName, 0)
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toLong()
        }
    }

    private fun currentPolicy(): AppVersionPolicy {
        val playStoreUrl = remoteConfig.getString(KEY_PLAY_STORE_URL)
            .ifBlank { defaultPlayStoreUrl() }

        return AppVersionPolicy(
            latestVersionCode = remoteConfig.getLong(KEY_LATEST_VERSION_CODE),
            minSupportedVersionCode = remoteConfig.getLong(KEY_MIN_SUPPORTED_VERSION_CODE),
            latestVersionName = remoteConfig.getString(KEY_LATEST_VERSION_NAME),
            forceMessage = remoteConfig.getString(KEY_FORCE_MESSAGE).ifBlank { DEFAULT_FORCE_MESSAGE },
            optionalMessage = remoteConfig.getString(KEY_OPTIONAL_MESSAGE).ifBlank { DEFAULT_OPTIONAL_MESSAGE },
            playStoreUrl = playStoreUrl,
        )
    }

    private fun defaultPlayStoreUrl(): String =
        "https://play.google.com/store/apps/details?id=${context.packageName}"
}
