package pi.ckadmin

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.IntentSenderRequest
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStatus
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability

private const val PLAY_STORE_PACKAGE = "com.android.vending"

class AppUpdateCoordinator(
    private val activity: AppCompatActivity,
    private val updateLauncher: ActivityResultLauncher<IntentSenderRequest>,
) {
    private val policyClient = AppVersionPolicyClient(activity)
    private val appUpdateManager: AppUpdateManager = AppUpdateManagerFactory.create(activity)

    private var activeForcedPolicy: AppVersionPolicy? = null
    private var optionalPromptShown = false

    fun checkForUpdates() {
        policyClient.fetchPolicy { policy ->
            if (policy == null) {
                logger.info("No update policy available; allowing app launch")
                return@fetchPolicy
            }

            val currentVersionCode = policyClient.currentVersionCode()
            when (policy.requirementFor(currentVersionCode)) {
                AppUpdateRequirement.FORCED -> {
                    logger.info("Forced app update required: current=$currentVersionCode min=${policy.minSupportedVersionCode}")
                    activeForcedPolicy = policy
                    startImmediateUpdateOrFallback(policy)
                }
                AppUpdateRequirement.OPTIONAL -> {
                    logger.info("Optional app update available: current=$currentVersionCode latest=${policy.latestVersionCode}")
                    showOptionalUpdateDialog(policy)
                }
                AppUpdateRequirement.NONE -> {
                    logger.info("App update not required: current=$currentVersionCode")
                }
            }
        }
    }

    fun resumeImmediateUpdateIfNeeded() {
        appUpdateManager.appUpdateInfo
            .addOnSuccessListener { appUpdateInfo ->
                when {
                    appUpdateInfo.installStatus() == InstallStatus.DOWNLOADED -> {
                        appUpdateManager.completeUpdate()
                    }
                    appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS -> {
                        appUpdateManager.startUpdateFlowForResult(
                            appUpdateInfo,
                            updateLauncher,
                            AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                        )
                    }
                }
            }
            .addOnFailureListener { error ->
                logger.warning("Failed to resume in-app update: $error")
            }
    }

    fun onUpdateResult(resultCode: Int) {
        if (resultCode == Activity.RESULT_OK) {
            activeForcedPolicy = null
            return
        }

        activeForcedPolicy?.let { policy ->
            logger.warning("Forced in-app update was cancelled or failed; showing Play Store fallback")
            showForcedUpdateDialog(policy)
        }
    }

    private fun startImmediateUpdateOrFallback(policy: AppVersionPolicy) {
        appUpdateManager.appUpdateInfo
            .addOnSuccessListener { appUpdateInfo ->
                val canStartImmediateUpdate =
                    appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                        appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)

                if (canStartImmediateUpdate) {
                    appUpdateManager.startUpdateFlowForResult(
                        appUpdateInfo,
                        updateLauncher,
                        AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                    )
                } else {
                    logger.info("Immediate in-app update unavailable; showing Play Store fallback")
                    showForcedUpdateDialog(policy)
                }
            }
            .addOnFailureListener { error ->
                logger.warning("Failed to query in-app update availability: $error")
                showForcedUpdateDialog(policy)
            }
    }

    private fun showForcedUpdateDialog(policy: AppVersionPolicy) {
        if (activity.isFinishing || activity.isDestroyed) { return }

        AlertDialog.Builder(activity)
            .setTitle("업데이트가 필요합니다")
            .setMessage(policy.forceMessage)
            .setCancelable(false)
            .setPositiveButton("업데이트") { _, _ ->
                openPlayStore(policy.playStoreUrl)
                showForcedUpdateDialog(policy)
            }
            .show()
    }

    private fun showOptionalUpdateDialog(policy: AppVersionPolicy) {
        if (optionalPromptShown || activity.isFinishing || activity.isDestroyed) { return }
        optionalPromptShown = true

        AlertDialog.Builder(activity)
            .setTitle("새 버전이 출시되었습니다")
            .setMessage(policy.optionalMessage)
            .setPositiveButton("업데이트") { _, _ ->
                openPlayStore(policy.playStoreUrl)
            }
            .setNegativeButton("나중에", null)
            .show()
    }

    private fun openPlayStore(webUrl: String) {
        val marketIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("market://details?id=${activity.packageName}"),
        ).apply {
            setPackage(PLAY_STORE_PACKAGE)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        try {
            activity.startActivity(marketIntent)
        } catch (_: ActivityNotFoundException) {
            activity.startActivity(
                Intent(Intent.ACTION_VIEW, Uri.parse(webUrl)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
        }
    }
}
