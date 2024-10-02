import 'package:jost_pay_wallet/Ui/Authentication/AuthScreen.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard/DashboardScreen.dart';

class SplashScreenAfter extends StatefulWidget {
  const SplashScreenAfter({super.key});

  @override
  State<SplashScreenAfter> createState() => _SplashScreenAfterState();
}

class _SplashScreenAfterState extends State<SplashScreenAfter> {

  checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if(token != null)
      {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
  }

  @override
  void initState() {
    checkToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
            left: 24.0, right: 24.0), // Padding around the widget
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image widget
              Image.asset("assets/images/splash/splash_screen_after.png",
                  width: double.infinity, fit: BoxFit.cover),
              const SizedBox(height: 32), // Space between image and text

              // Text widget
              Text('Buy & Sell Crypto',
                  style: NewStyle.tx28White.copyWith(fontSize: 30)),
              const SizedBox(height: 9), // Space between text and button

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 46.0),
                child: Text(
                  'Effortlessly buy or sell digital asset with speed and convenience.',
                  style: NewStyle.tx14SplashWhite,
                  textAlign: TextAlign.center,
                ),
              ),
              // ElevatedButton widget
              const SizedBox(height: 120),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthScreen())),
                    style: TextButton.styleFrom(
                      backgroundColor: NewColor.mainWhiteColor,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text("Get me in",
                        style: NewStyle.btnTx16SplashBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
