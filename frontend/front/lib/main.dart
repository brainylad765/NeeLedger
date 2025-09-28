import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:front/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- 1. IMPORT SUPABASE

import 'firebase_options.dart';
import 'providers/user_provider.dart';

void main() async {
  // This is required to ensure bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Your existing Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // <-- 2. ADD SUPABASE INITIALIZATION HERE
  await Supabase.initialize(
    url: 'https://sdnwzesuiulljxmwxpob.supabase.co',       // Replace with your Project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbnd6ZXN1aXVsbGp4bXd4cG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNDk5NjEsImV4cCI6MjA3NDYyNTk2MX0.cHjCwwKpq7s1EjNWP-1dzXHnnd8iNP-9MdBGNeC9Jas', // Replace with your anon key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'NeeLedger',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const WelcomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
