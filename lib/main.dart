import 'package:sentra/firebase_options.dart';
import 'package:sentra/features/auth/controllers/login_controller.dart';
import 'package:sentra/features/auth/controllers/forgot_password_controller.dart';
import 'package:sentra/features/auth/controllers/register_controller.dart';
import 'package:sentra/features/auth/services/auth_session.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/chat/controllers/chat_controller.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/notification/services/notif_service.dart';
import 'package:sentra/features/splash/splash_screen.dart';
import 'package:sentra/features/welcome/welcome_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  await dotenv.load(fileName: ".env");

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
      builder:
          (context) => MultiProvider(
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
      theme: ThemeData(fontFamily: 'Mulish'),
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const StartupGate(),
    );
  }
}

/// Memulihkan sesi sebelum menentukan halaman awal.
///
/// Sesi tersimpan divalidasi ke server memakai endpoint yang tersedia
/// (POST /auth/biometric). Bila server tidak dapat dihubungi, sesi lokal
/// tetap dipakai agar aplikasi dapat dibuka secara offline.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  static const Duration _minimumSplash = Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final startedAt = DateTime.now();
    UserModel? user;
    try {
      user = await AuthSession.restore();
    } catch (_) {
      user = null;
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minimumSplash) {
      await Future.delayed(_minimumSplash - elapsed);
    }

    if (!mounted) return;

    if (user != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 0)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeWithSplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(autoNavigate: false);
  }
}
