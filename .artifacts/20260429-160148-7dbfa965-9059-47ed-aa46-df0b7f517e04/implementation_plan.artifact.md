# Fix Braintree Module Resolution and API Usage

This plan fixes the Braintree SDK integration in the iOS Runner by resolving module name mismatches and updating the code to match the API of Braintree v5.

## Proposed Changes

### iOS Configuration

#### [Podfile](file:///Users/tvf/titan-dev/magnes-sdk-integration-sample/ios/Podfile)
- Use `use_frameworks! :linkage => :static` to ensure better compatibility with Flutter and Swift/Obj-C mixed dependencies.
- Ensure the `Braintree` pod with `DataCollector` subspec is used.

#### [Debug.xcconfig](file:///Users/tvf/titan-dev/magnes-sdk-integration-sample/ios/Flutter/Debug.xcconfig) and [Release.xcconfig](file:///Users/tvf/titan-dev/magnes-sdk-integration-sample/ios/Flutter/Release.xcconfig)
- Fix the include path for CocoaPods configurations from `Pods/...` to `../Pods/...`.

### Application Logic

#### [AppDelegate.swift](file:///Users/tvf/titan-dev/magnes-sdk-integration-sample/ios/Runner/AppDelegate.swift)
- Change imports to use the unified `Braintree` module.
- Update `collectDeviceData` closure to accept a single `deviceData` argument as required by Braintree v5.27.0.

```diff
-      dataCollector.collectDeviceData { deviceData, error in
-          if let error = error {
-              flutterResult(FlutterError(code: "UNAVAILABLE", message: error.localizedDescription, details: nil))
-          } else if let deviceData = deviceData {
-              // Returns a stringified JSON containing the correlation_id
-              flutterResult(deviceData)
-          } else {
-              flutterResult(FlutterError(code: "UNKNOWN", message: "Failed to collect data", details: nil))
-          }
-      }
+      dataCollector.collectDeviceData { deviceData in
+          // In this version of the SDK, deviceData is non-null and the closure
+          // is only called upon success or with default data.
+          flutterResult(deviceData)
+      }
```

## Verification Plan

### Automated Tests
- `flutter build ios --no-codesign` to verify that the project compiles and links correctly.

### Manual Verification
- Verify that `AppDelegate.swift` has no syntax errors using `analyze_file`.
