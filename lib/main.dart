import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentra/firebase_options.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/logincontroller.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/lupapasswordcontroller.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/registercontroller.dart';
import 'package:sentra/fitur/authentikasi/data/localdirectory/akunprefs.dart';
import 'package:sentra/fitur/authentikasi/data/models/usermodel.dart';
import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/chat/data/controllers/chatcontroller.dart';
import 'package:sentra/fitur/dashboard/screen/views/homescreen.dart';
import 'package:sentra/fitur/notifikasi/data/controllers/notifcontroller.dart';
import 'package:sentra/fitur/notifikasi/service/notifservice.dart';
import 'package:sentra/fitur/splashscreen/splashscreen.dart';
import 'package:sentra/fitur/welcomescreen/welcomescreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Handler untuk notifikasi background
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
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // await GoogleSignIn().init();
  await SharedPreferences.getInstance();
  //tangani notifikasi foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      NotificationService().showNotification(
        message.notification!.title ?? "Notifikasi Baru",
        message.notification!.body ?? "Pesan baru diterima",
      );
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => RegisterController()),
        ChangeNotifierProvider(create: (_) => LupaPasswordController()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: FutureBuilder<Map<String, String?>>(
        future: AkunPrefs.getAkun(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // Tampilkan SplashScreen saat memeriksa AkunPrefs
          } else if (snapshot.hasError) {
            // Tangani error dengan mengarahkan ke WelcomeWithSplashScreen
            return WelcomeWithSplashScreen();
          } else {
            final userData = snapshot.data;
            // Periksa apakah data akun valid (id_akun tidak null atau kosong)
            if (userData != null &&
                userData['id_akun'] != null &&
                userData['id_akun']!.isNotEmpty) {
              // Konversi Map<String, String?> ke UserModel
              final userModel = UserModel(
                id: int.tryParse(userData['id_akun'] ?? '') ?? 0,
                nama: userData['nama'],
                notelp: userData['notelp'],
                email: userData['email'] ?? '',
                role: userData['role'] ?? '',
                alamat: userData['alamat'] ?? '',
                jeniskelamin: userData['jenis_kelamin'] ?? '',
              );
              // Set data pengguna ke UserProvider
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              userProvider.setUser(userModel);
              return SplashScreen(); // Langsung ke HomeScreen jika akun valid
            } else {
              // Ke WelcomeWithSplashScreen jika tidak ada data akun atau tidak valid
              return WelcomeWithSplashScreen();
            }
          }
        },
      ),
    );
  }
}
