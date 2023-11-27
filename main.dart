import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:malina/bindings/auth_binding.dart';
import 'package:malina/constants/constants.dart';
import 'package:malina/firebase_options.dart';
import 'package:malina/services/services.dart';
import 'package:malina/views/components/components.dart';

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imageCache = super.createImageCache();
    // Set your image cache size
    imageCache.maximumSizeBytes = 1024 * 1024 * 200; // 200 MB
    return imageCache;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {};

  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (kReleaseMode) {
    CustomImageCache();
  }

  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: "malina",
        channelName: "Basic sound notifications",
        channelDescription: "Notifications with basic sound",
        playSound: true,
        // soundSource: 'resource://raw/res_notif',
        defaultColor: Colors.transparent,
        ledColor: Colors.blue,
        vibrationPattern: highVibrationPattern,
        importance: NotificationImportance.High,
      ),
    ],
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Update the iOS foreground notification presentation options to allow heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await GetStorage.init();

  // await initializeDateFormatting("ru");
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Loading(
      child: GetMaterialApp(
        color: Color(0XFF0A114F),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('ru')],
        debugShowCheckedModeBanner: false,
        title: 'Malina',
        theme: AppThemes.lightTheme,
        initialRoute: '/splash',
        getPages: AppRoutes.routes,
        initialBinding: AuthBinding(),
      ),
    );
  }
}
