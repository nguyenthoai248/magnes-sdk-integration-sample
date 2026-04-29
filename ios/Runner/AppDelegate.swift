import UIKit
import Flutter
import Braintree
 
@main
@objc class AppDelegate: FlutterAppDelegate {
  private var magnesChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Register the channel using the registrar for better reliability
    let registrar = self.registrar(forPlugin: "MagnesPlugin")
    if let messenger = registrar?.messenger() {
        print("Magnes: Registering method channel via registrar")
        self.magnesChannel = FlutterMethodChannel(name: "com.paypal.demo/magnes",
                                                  binaryMessenger: messenger)
        self.magnesChannel?.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          print("Magnes: Received method call: \(call.method)")
          if call.method == "getClientMetadataId" {
              self?.getMagnesData(flutterResult: result)
          } else {
              result(FlutterMethodNotImplemented)
          }
        })
    } else {
        print("Magnes: Failed to get messenger from registrar")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getMagnesData(flutterResult: @escaping FlutterResult) {
      print("Magnes: Collecting data...")
      // Initialize an API Client using your Tokenization Key or Client Token
      guard let apiClient = BTAPIClient(authorization: "sandbox_7xtbb6zw_dkvdjkwcddjxkmb9") else {
          print("Magnes: Error - Invalid token")
          flutterResult(FlutterError(code: "INVALID_TOKEN", message: "Invalid Braintree tokenization key", details: nil))
          return
      }
      let dataCollector = BTDataCollector(apiClient: apiClient)
      // Collect device data
      dataCollector.collectDeviceData { deviceData in
          print("Magnes: Data collected successfully")
          // Returns a stringified JSON containing the correlation_id
          flutterResult(deviceData)
      }
  }
}
