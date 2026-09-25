import 'package:sentra/firebase_options.dart';
import 'package:sentra/features/auth/controllers/login_controller.dart';
import 'package:sentra/features/auth/controllers/forgot_password_controller.dart';
import 'package:sentra/features/auth/controllers/register_controller.dart';
import 'package:sentra/features/auth/preferences/account_prefs.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/chat/controllers/chat_controller.dart';
import 'package:sentra/features/notification/services/notif_service.dart';
import 'package:sentra/features/splash/splash_screen.dart';
import 'package:sentra/features/welcome/welcome_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  if (message.notification != null) {
    NotificationService().showNotification(
      message.notification!.title ?? "Notifikasi Baru",
      message.notification!.body ?? "Pesan baru diterima",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await NotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService().showNotification(
          message.notification!.title ?? "Notifikasi Baru",
          message.notification!.body ?? "Pesan baru diterima",
        );
      }
    });
  }

  await SharedPreferences.getInstance();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginController()),
          ChangeNotifierProvider(create: (_) => RegisterController()),
          ChangeNotifierProvider(create: (_) => LupaPasswordController()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ChatController()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: FutureBuilder<Map<String, String?>>(
        future: AkunPrefs.getAkun(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); 
          } else if (snapshot.hasError) {
            
            return WelcomeWithSplashScreen();
          } else {
            final userData = snapshot.data;
            if (userData != null &&
                userData['id_akun'] != null &&
                userData['id_akun']!.isNotEmpty) {
              final userModel = UserModel(
                id: int.tryParse(userData['id_akun'] ?? '') ?? 0,
                nama: userData['nama'],
                notelp: userData['notelp'],
                email: userData['email'] ?? '',
                role: userData['role'] ?? '',
                alamat: userData['alamat'] ?? '',
                jeniskelamin: userData['jenis_kelamin'] ?? '',
              );
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              userProvider.setUser(userModel);
              return SplashScreen(); 
            } else {   
              return WelcomeWithSplashScreen();
            }
          }
        },
      ),
    );
  }
}
