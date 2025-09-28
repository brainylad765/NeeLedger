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
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ merged import
import 'firebase_options.dart';
import 'auth_gate.dart'; // ✅ added

import 'utils/constants.dart';

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
import 'screens/blockzen/login/login_screen.dart';
import 'screens/blockzen/dashboard_screen.dart';
import 'providers/user_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/evidence_provider.dart';
import 'providers/document_provider.dart';
import 'providers/upload_provider.dart';
import 'screens/project_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Supabase initialization merged
  await Supabase.initialize(
    url: 'https://sdnwzesuiulljxmwxpob.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbnd6ZXN1aXVsbGp4bXd4cG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNDk5NjEsImV4cCI6MjA3NDYyNTk2MX0.cHjCwwKpq7s1EjNWP-1dzXHnnd8iNP-9MdBGNeC9Jas',
  );

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
              theme: ThemeData(
                brightness: Brightness.light,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: kBackground,
                cardColor: kCard,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ).apply(bodyColor: Colors.white),
                appBarTheme: const AppBarTheme(backgroundColor: kSurface),
                colorScheme: ColorScheme.dark(
                  primary: kAccent,
                  secondary: kAccent,
                ),
              ),
              initialRoute: '/',
              debugShowCheckedModeBanner: false, // ✅ added
              routes: {
                '/': (context) => const AuthGate(),
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
              },
            ),
          ),
        );
      },
    );
  }
}
