import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mend_doctor/pages/pageEvent.dart';
import 'package:mend_doctor/pages/pageEventInvoice.dart';
import 'package:mend_doctor/pages/pageEventList.dart';
import 'package:mend_doctor/pages/pageEventProgramDetails.dart';
import 'package:mend_doctor/pages/pageEventSchedule.dart';
import 'package:mend_doctor/pages/pageEventSpeakerDetails.dart';
import 'package:mend_doctor/pages/pageFirst.dart';
import 'package:mend_doctor/pages/pageInitialize.dart';
import 'package:mend_doctor/pages/pageLogin.dart';
import 'package:mend_doctor/pages/pageProfile.dart';
import 'package:mend_doctor/pages/pageQRscan.dart';
import 'package:mend_doctor/singletons/service_locator.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/utils/notificationFirebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  eventData.resetData();
  eventData.firebaseMessaging = FirebaseMessaging();
  runApp(MyApp());
}
class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {

    super.initState();
    // EventBus eventBus = new EventBus();
    eventData.firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        /// ene ashiglagdahgui, zowhon onLaunch, onResume callback uud duudagdana
        /// Page bolgon deer implement hiisen. daraa n tsegtselne biz
        dynamic notification = message['notification'];
        NotificationFirebase(context, notification['title'] ?? '', notification['body'] ?? '').showNotification();
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        ///TODO: app terminate hiigdsen ued duudagdah CALLBACK
        ///shuud tuhain page ruu n usergeh
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        ///TODO: app background-d baih ued duudagdah CALLBACK
        ///shuud tuhain page ruu n usergeh
      },
    );
    eventData.firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    eventData.firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    eventData.firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print('token = ' + token);
      saveTokenToPrefs(token);

    });
  }

  void saveTokenToPrefs(String token) {
    eventData.firebaseToken = token;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff021863),
      statusBarBrightness: Brightness.dark
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mend - MedTech',
      initialRoute: '/',
//      initialRoute: LoginPage.routeName,
      routes: {

        '/': (context) => InitializePage(),
//        '/': (context) => IntroScreen(),
        LoginPage.routeName: (context) => LoginPage(),
        FirstPage.routeName: (context) => FirstPage(),
        EventPage.routeName: (context) => EventPage(),
        ProfilePage.routeName: (context)=> ProfilePage(),
        EventSchedule.routeName: (context)=>EventSchedule(),
        EventListPage.routeName: (context)=>EventListPage(),
        EventProgramDetailsPage.routeName: (context)=>EventProgramDetailsPage(),
        EventSpeakerDetailsPage.routeName: (context)=>EventSpeakerDetailsPage(),
        QRViewScan.routeName: (context) => QRViewScan(),
        EventInvoicePage.routeName: (context) => EventInvoicePage(),
      },
      theme: ThemeData(
        backgroundColor: Colors.white,
        primaryColor: Colors.white,
        primaryIconTheme: const IconThemeData.fallback().copyWith(
          color: Colors.white,
        ),
        fontFamily: 'SFProDisplay',
      ),
    );
  }
}
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  ///TODO:
  ///background message heregleh ued ashiglah callback
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print('data: $data');
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print('notification: $notification');
  }

  // Or do other work.
  return Future<void>.value();
}

