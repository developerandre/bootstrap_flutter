import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'firebase_options.dart';
import 'main.dart';
import 'providers/model.dart';
import 'providers/routing_config.dart';
import 'providers/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? msg;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Timer(const Duration(milliseconds: 350), () {
        initApp();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.asset(
                'assets/img1.jpeg',
                //fit: BoxFit.contain,
                //height: 200,
                //width: MediaQuery.of(context).size.width
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                  child: const Text(appNameDescription,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600))
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 300))))
        ])));
  }

  void initApp() async {
    try {
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .then((value) async {
        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);
        if (!kIsWeb && !Platform.isWindows) {
          await setupFlutterNotifications();
        }
      });

      if (!kIsWeb) {
        if (Platform.isIOS || Platform.isAndroid) {
          await Hive.initFlutter();
        } else {
          String path = Directory.current.path;
          path = p.join(path, 'storage');
          Hive.init(path);
        }
        await Hive.initFlutter();
      }

      if (!kIsWeb) {
        Services.appDirectory = (await getApplicationDocumentsDirectory()).path;
      }
      Box box = await Hive.openBox('settings');
      await Hive.openBox('data');
      _initApp(box: box);
    } catch (e) {
      debugPrint("$e");
    }
  }

  void _initApp({required Box box}) async {
    try {
      //await Hive.box('settings').clear();
      //await Services.instance.fillMockData();
      bool tutorial = Hive.box('settings').get('tutorial', defaultValue: false);
      if (!tutorial) {
        context.goNamed(AppRouteConstants.tutorial);
        return;
      }
      String? token = Hive.box('settings').get('token');
      Map user = box.get('user') ?? {};
      print('user $user');
      if (user.isEmpty || user['name'] == null) {
        context.goNamed(AppRouteConstants.login);
        return;
      }

      Services.token = token;
      bool haveData = box.get('haveData', defaultValue: false);
      Services.user = UserAccount.addFromMap(user);
      if (!haveData) {
        context.goNamed(AppRouteConstants.init);
        return;
      }

      context.goNamed(AppRouteConstants.dashboard);
    } catch (_) {
      //print(_);
      context.goNamed(AppRouteConstants.tutorial);
    }
  }
}
