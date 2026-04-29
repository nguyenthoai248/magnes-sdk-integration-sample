import UIKit
import Flutter
import PPRiskMagnes
 
@main
@objc class AppDelegate: FlutterAppDelegate {
  private var magnesChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let applicationResult = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    GeneratedPluginRegistrant.register(with: self)

    setupMagnesSDK()
    registerMagnesChannel()

    return applicationResult
  }

  private func registerMagnesChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("Magnes: Failed to get FlutterViewController in AppDelegate")
      return
    }

    print("Magnes: Registering method channel in AppDelegate")
    self.magnesChannel = FlutterMethodChannel(name: "com.paypal.demo/magnes",
                                              binaryMessenger: controller.binaryMessenger)
    self.magnesChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      print("Magnes: Received method call: \(call.method)")
      if call.method == "getClientMetadataId" {
        self?.getMagnesData(flutterResult: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }

  private func setupMagnesSDK() {
      do {
          try MagnesSDK.shared().setUp(
              setEnviroment: .SANDBOX,
              setOptionalAppGuid: "",
              setOptionalAPNToken: "",
              disableRemoteConfiguration: false,
              disableBeacon: false,
              magnesSource: .DEFAULT)
          print("Magnes: SDK initialized")
      } catch {
          print("Magnes: SDK setup failed: \(error)")
      }
  }

  private func getMagnesData(flutterResult: @escaping FlutterResult) {
      print("Magnes: Collecting data...")
      let magnes = MagnesSDK.shared()
      let magnesResult = magnes.collectAndSubmit()
      let cmid = magnesResult.getPayPalClientMetaDataId()
      print("Magnes: Data collected successfully")
      flutterResult(cmid)
  }
}
