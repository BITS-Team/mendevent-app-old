import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mend_doctor/pages/pageLogin.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;

class FirstPage extends StatefulWidget {
  static const routeName = '/firstPage';
  @override
  FirstPageState createState() {
    // TODO: implement createState
    return FirstPageState();
  }
}

class FirstPageState extends State<FirstPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//      systemNavigationBarColor: Colors.blue, // navigation bar color
      statusBarColor: Color.fromARGB(255, 2, 24, 99), // status bar color
    ));
    // TODO: implement build
    return Scaffold(
        body: Column(children: <Widget>[
      Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 20),
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          color: Color.fromARGB(255, 2, 24, 99),
          child: Image(
            image: AssetImage("assets/logo_without_text.png"),
            height: MediaQuery.of(context).size.height * 0.45 / 4,
          )),
      Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          color: Color.fromARGB(255, 2, 24, 99),
          child: Image(
            image: AssetImage("assets/logo_text.png"),
            height: MediaQuery.of(context).size.height * 0.04,
          )),
      Container(
        alignment: Alignment.bottomCenter,
        width: MediaQuery.of(context).size.width,
        child: new Image(
          image: new AssetImage("assets/top_bg.png"),
          color: null,
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 20, bottom: 5),
        child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, LoginPage.routeName);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 2 / 5,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 2, 24, 99),
                borderRadius: BorderRadius.all(const Radius.circular(10)),
              ),
              child: Center(
                  child: Text(
                'Нэвтрэх'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              )),
            )),
      ),
      InkWell(
          onTap: () {
            Navigator.pushNamed(context, LoginPage.routeName);
          },
          child: Container(
              //TODO: using InkWell, same enter btn
              padding: EdgeInsets.only(top: 10, bottom: 50),
              child: Container(
                width: MediaQuery.of(context).size.width * 2 / 5,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: sData.StaticData.yellowLogo,
                  borderRadius: sData.StaticData.r10,
                ),
                child: Center(
                    child: Text(
                  'бүртгүүлэх'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )),
              ))),
    ]));
  }
}
