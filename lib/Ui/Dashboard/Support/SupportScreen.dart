import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

  late InAppWebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child:Stack(
          children: [
            InAppWebView(
              initialUrlRequest:URLRequest(
                  url: Uri.parse("https://tawk.to/chat/56f3c326d19f288b7cc160b5/default")
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  useShouldOverrideUrlLoading: false,
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                ),
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },

              onLoadStop: (controller, url) async {
                bool check  = await controller.isLoading();
                if(!check){
                  setState(() {
                    isLoading = false;
                  });
                }
              },
            ),

            Visibility(
              visible: isLoading,
              child: const Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  )
              ),
            ),

          ],
        ),
      )
    );
  }
}
