import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart'; // ✅ added

import 'utils/constants.dart';
import 'themes/app_theme.dart';

import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payment_verification_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen_new.dart';
import 'screens/data_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/market_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/uploads_screen.dart';
import 'screens/debug_uploads_screen.dart';
import 'screens/blockzen/login/login_screen.dart';
import 'screens/blockzen/dashboard_screen.dart';
import 'providers/user_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/evidence_provider.dart';
import 'providers/document_provider.dart';
import 'providers/upload_provider.dart';
import 'providers/project_provider.dart';
import 'providers/buffer_pool_provider.dart';
import 'screens/yourprojects_screen.dart';
import 'screens/buffer_pool_screen.dart';
import 'screens/nextlogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ WebView setup only for Android devices
  if (!kIsWeb) {
    try {
      if (Platform.isAndroid) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      }
    } catch (e) {
      debugPrint('Platform check failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = TransactionProvider();
            provider.addSampleTransactions();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => EvidenceProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => BufferPoolProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final MaterialColor blueSwatch =
      MaterialColor(0xFF0D47A1, <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      });

  @override
  Widget build(BuildContext context) {
    // ✅ Constrain width for mobile-style UI on web/desktop
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 420
            ? 420.0
            : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: maxWidth,
            child: MaterialApp(
              title: 'NeeLedger',
              themeMode: ThemeMode.dark,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              // initialRoute: '/',  // Removed to force home screen
              debugShowCheckedModeBanner: false, // ✅ added
              // Removed home to avoid conflict with '/' route
              routes: {
                '/': (context) => const WelcomeScreen(),
                WelcomeScreen.routeName: (context) => const WelcomeScreen(),
                OnboardingScreen.routeName: (context) =>
                    const OnboardingScreen(),
                LoginScreen.routeName: (context) => const LoginScreen(),
                PaymentVerificationScreen.routeName: (context) =>
                    const PaymentVerificationScreen(),
                DashboardScreen.routeName: (context) => const DashboardScreen(),
                HomeScreen.routeName: (context) => const HomeScreen(),
                DataScreen.routeName: (context) => const DataScreen(),
                ProjectsScreen.routeName: (context) => const ProjectsScreen(),
                MarketScreen.routeName: (context) => const MarketScreen(),
                WalletScreen.routeName: (context) => const WalletScreen(),
                ProfileScreen.routeName: (context) => const ProfileScreen(),
                BlockZenLoginScreen.routeName: (context) =>
                    const BlockZenLoginScreen(),
                BlockZenDashboardScreen.routeName: (context) =>
                    const BlockZenDashboardScreen(),
                UploadsScreen.routeName: (context) => const UploadsScreen(),
                DebugUploadsScreen.routeName: (context) =>
                    const DebugUploadsScreen(),
                '/your-projects': (context) => const YourProjectsScreen(),
                '/nextlogin': (context) => const NextLogin(),
                BufferPoolScreen.routeName: (context) =>
                    const BufferPoolScreen(),
              },
            ),
          ),
        );
      },
    );
  }
}
