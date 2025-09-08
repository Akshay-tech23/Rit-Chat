import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rit_chat/core/theme/app_theme.dart';
import 'package:rit_chat/presentation/screens/auth/login_screen.dart';
import 'package:rit_chat/presentation/screens/auth/onboarding_screen.dart';
import 'package:rit_chat/presentation/screens/home/home_screen.dart';
import 'firebase_options.dart'; 
import 'core/config/app_config.dart';
import 'presentation/bloc/app_observer.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppConfig.init();
  Bloc.observer = AppBlocObserver();
  runApp(const RITChatApp());
}

class RITChatApp extends StatelessWidget {
  const RITChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RITCHAT',
      theme: AppTheme.lightTheme,   
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
