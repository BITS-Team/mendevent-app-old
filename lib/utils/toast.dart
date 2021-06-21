import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final toast = ToastHelper();
class ToastHelper {
  void show(String message, {gravity: ToastGravity.BOTTOM, length: 1}) {
    Toast toastLength;
    int timeInSecForIosWeb;

    if(length == 1){
      toastLength = Toast.LENGTH_SHORT;
      timeInSecForIosWeb = 2;
    } else if (length == 2){
      toastLength = Toast.LENGTH_LONG;
      timeInSecForIosWeb = 3;
    } else {
      toastLength = Toast.LENGTH_SHORT;
      timeInSecForIosWeb = 1;
    }

    Fluttertoast.showToast(msg: message,
        toastLength: toastLength,
        gravity: gravity,
        timeInSecForIosWeb: timeInSecForIosWeb,
        backgroundColor: Color(0xff021863),
        textColor: Colors.white,
        fontSize: 15.0);
  }
}