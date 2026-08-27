package com.example.erp_mobile_app

import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    private val attendanceSecurityChannel = "tpg_nexus/attendance_security"

    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            attendanceSecurityChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAttendanceSecurityRisk" -> result.success(getAttendanceSecurityRisk())
                else -> result.notImplemented()
            }
        }
    }

    private fun getAttendanceSecurityRisk(): Map<String, Any> {
        return mapOf(
            "root_or_jailbreak_detected" to isRootedDevice(),
            "developer_mode_detected" to isDeveloperModeEnabled(),
            "mock_location_enabled" to isMockLocationSettingEnabled()
        )
    }

    private fun isDeveloperModeEnabled(): Boolean {
        return try {
            Settings.Global.getInt(
                contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) == 1
        } catch (_: Exception) {
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun isMockLocationSettingEnabled(): Boolean {
        return try {
            Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ALLOW_MOCK_LOCATION
            ) == "1"
        } catch (_: Exception) {
            false
        }
    }

    private fun isRootedDevice(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        if (paths.any { File(it).exists() }) return true

        val tags = android.os.Build.TAGS
        return tags != null && tags.contains("test-keys")
    }
}
