import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:mend_doctor/pages/pageLogin.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = '/introPage';
  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final1.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundBlendMode: BlendMode.difference,
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final2.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final3.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
        onCenterItemPress: () {},
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final4.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      )
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final5.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final6.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final7.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final8.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Container(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Image.asset('assets/intro_final9.gif',  fit: BoxFit.fill,)
        ),
        backgroundImage: 'assets/intro_bg.png',
        backgroundImageFit: BoxFit.fill,
        backgroundBlendMode: BlendMode.difference,
      ),
    );
  }

  void onDonePress() {
    // Do what you want
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => FirstPage()),
//    );
    Navigator.pushNamed(
      context,
      LoginPage.routeName, //MaterialPageRoute
    );
  }

  Widget renderNextBtn() {
    return Container(
        padding: EdgeInsets.all(5),
        child: Text(
          'Удаах'
        )
//        Icon(
//          Icons.navigate_next,
//          color: Color(0xff021863),
////      size: 35.0,
//        ),
    );
  }

  Widget renderDoneBtn() {
    return Container(
        padding: EdgeInsets.all(5),
        child: Text(
          'Нэвтэр'
        )
//        Icon(
//          Icons.done,
//          color: Color(0xff021863),
//        )
    );
  }

  Widget renderSkipBtn() {
    return Container(
        padding: EdgeInsets.all(5),
        child: Text(
          'Алгас'
        )
//        Icon(
//          Icons.clear,
//          color: Color(0xff021863),
//        )
    );
//    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      // List slides
      slides: this.slides,

      // Skip button
      renderSkipBtn: this.renderSkipBtn(),
      colorSkipBtn: Color(0xffEEEEEE),
      highlightColorSkipBtn: Color(0xffEEEEEE),

      // Next button
      renderNextBtn: this.renderNextBtn(),

      // Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      colorDoneBtn: Color(0xffEEEEEE),
      highlightColorDoneBtn: Color(0xffEEEEEE),

      // Dot indicator
      colorDot: Color(0x33fdb92e),
      colorActiveDot: Color(0xfffdb92e),
      sizeDot: 5.0,

      // Show or hide status bar
      shouldHideStatusBar: true,
      backgroundColorAllSlides: Color(0xFFFFFFFF),
    );
  }
}
