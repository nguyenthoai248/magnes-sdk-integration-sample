package com.example.magnes_sdk_integration_sample

import com.braintreepayments.api.datacollector.DataCollector
import com.braintreepayments.api.datacollector.DataCollectorRequest
import com.braintreepayments.api.datacollector.DataCollectorResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import lib.android.paypal.com.magnessdk.MagnesSDK

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
        // hasUserLocationConsent requires you to comply with Play Store policies
        // If false, it still collects basic data but skips precise location.
        val dataCollectorRequest = DataCollectorRequest(false)
        
        // In v5+ of the Android SDK, authorization is passed directly or 
        // you can use the context-only initializer for basic device data.
        val dataCollector = DataCollector(this, "sandbox_7xtbb6zw_dkvdjkwcddjxkmb9")
        
        dataCollector.collectDeviceData(this, dataCollectorRequest) { result ->
            when (result) {
                is DataCollectorResult.Success -> {
                    // deviceData contains the JSON payload holding the correlation ID
                    flutterResult.success(result.deviceData)
                }
                is DataCollectorResult.Failure -> {
                    flutterResult.error("UNAVAILABLE", result.error.message, null)
                }
            }
        }
    }
}
