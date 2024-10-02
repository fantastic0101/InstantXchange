import 'package:jost_pay_wallet/Ui/Static/SplashScreenAfter.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 30.0, // Top padding
          left: 24.0, // Left padding
          right: 24.0,
        ), // Padding around the widget
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image widget
              Image.asset("assets/images/splash/splash_screen.png",
                  fit: BoxFit.cover),
              const SizedBox(height: 31.3), // Space between image and text

              // Text widget
              const Text('Manage Crypto Easily', style: NewStyle.tx28White),
              const SizedBox(height: 7), // Space between text and button

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Store, send, and receive crypto. Instantly withdraw to your bank',
                  style: NewStyle.tx14SplashWhite,
                  textAlign: TextAlign.center,
                ),
              ),
              // ElevatedButton widget
              const SizedBox(height: 52),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreenAfter())),
                    style: TextButton.styleFrom(
                      backgroundColor: NewColor.mainWhiteColor,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child:
                        const Text("Next", style: NewStyle.btnTx16SplashBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
