import UIKit
import Flutter
import PPRiskMagnes
 
@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)
    setupMagnesSDK()
    registerMagnesChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerMagnesChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      log("Failed to get FlutterViewController")
      return
    }

    log("Registering method channel")
    let magnesChannel = FlutterMethodChannel(
      name: "com.paypal.demo/magnes",
      binaryMessenger: controller.binaryMessenger
    )

    magnesChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleMagnesMethod(call: call, result: result)
    })
  }

  private func handleMagnesMethod(call: FlutterMethodCall, result: @escaping FlutterResult) {
    log("Received method call: \(call.method)")

    switch call.method {
    case "getClientMetadataId":
      getMagnesData(flutterResult: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setupMagnesSDK() {
    do {
      try MagnesSDK.shared().setUp(magnesSource: .DEFAULT)
      log("SDK initialized")
    } catch {
      log("SDK setup failed: \(error)")
    }
  }

  private func getMagnesData(flutterResult: @escaping FlutterResult) {
    log("Collecting Magnes metadata")

    let magnes = MagnesSDK.shared()
    let magnesResult = magnes.collectAndSubmit()
    let cmid = magnesResult.getPayPalClientMetaDataId()

    guard !cmid.isEmpty else {
      log("Failed to obtain client metadata ID")
      flutterResult(FlutterError(
        code: "MAGNES_NO_CMID",
        message: "Could not collect Magnes client metadata ID.",
        details: nil
      ))
      return
    }

    log("Data collected successfully")
    flutterResult(cmid)
  }

  private func log(_ message: String) {
    NSLog("Magnes: %@", message)
  }
}
