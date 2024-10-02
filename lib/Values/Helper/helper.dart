import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';

class Helper {
  static final Helper dialogCall = Helper._();

  Helper._();

  showToast(context,String messages){
    Fluttertoast.showToast(
        msg: messages,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: MyColor.darkGrey01Color,
        textColor: MyColor.whiteColor,
        fontSize: 15.0
    );
  }


  showLoader(){
    return const Center(
        child: CircularProgressIndicator(
          color: MyColor.greenColor,
        )
    );
  }

  showAlertDialog(BuildContext context){
    AlertDialog alert =  AlertDialog(
      backgroundColor:MyColor.boarderColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: const Row(
        children: [
          CircularProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(MyColor.greenColor),
          ),

          SizedBox(width: 20),
          Text("Loading...",
            style: TextStyle(
              fontSize: 18,
              color: MyColor.whiteColor,
            ),
          ),
        ],
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }


}