import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MagnesDemoApp());
}

class MagnesDemoApp extends StatelessWidget {
  const MagnesDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magnes SDK Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CheckoutScreen(),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Define the Method Channel matching the native code
  static const platform = MethodChannel('com.paypal.demo/magnes');

  String _cmidStatus = "Ready to collect data.";

  Future<void> _collectRiskData() async {
    setState(() {
      _cmidStatus = "Collecting device signals...";
    });

    try {
      // Invoke the native method
      final String? result = await platform.invokeMethod('getClientMetadataId');
      setState(() {
        _cmidStatus = "Success! CMID: \n\n$result";
      });
      print("Send this ID to your backend: $result");
    } on PlatformException catch (e) {
      setState(() {
        _cmidStatus = "Error: '${e.message}'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Risk Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _cmidStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _collectRiskData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Simulate Checkout',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
