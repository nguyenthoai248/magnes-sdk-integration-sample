package com.example.magnes_sdk_integration_sample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import lib.android.paypal.com.magnessdk.MagnesSDK
import lib.android.paypal.com.magnessdk.MagnesSettings
import lib.android.paypal.com.magnessdk.MagnesSource

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.paypal.demo/magnes"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getClientMetadataId") {
                getMagnesData(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getMagnesData(flutterResult: MethodChannel.Result) {
        try {
            // 1. Configure Magnes Settings
            val magnesSettings = MagnesSettings.Builder(this)
                .setMagnesSource(MagnesSource.DEFAULT)
                .build()

            // 2. Initialize the Singleton
            val magnesSDK = MagnesSDK.getInstance()
            magnesSDK.setUp(magnesSettings)

            // 3. Collect and Submit
            // This returns a MagnesResult object synchronously
            val magnesResult = magnesSDK.collectAndSubmit(this)

            // 4. Extract the PayPal Client Metadata ID (CMID)
            val cmid = magnesResult.paypalClientMetaDataId

            flutterResult.success(cmid)
        } catch (e: Exception) {
            flutterResult.error("MAGNES_ERROR", e.message, null)
        }
    }
}
