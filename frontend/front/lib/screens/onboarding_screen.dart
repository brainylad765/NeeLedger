import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen_new.dart';
import 'blockzen/login/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = '/';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themePrimary = const Color(0xFF0D47A1);
    return Scaffold(
      backgroundColor: themePrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / emblem
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 20),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 46),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'BC',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  "NeeLedger",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle / tagline
                Text(
                  "Trusted market for coastal carbon credits",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // Short blurb
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    "Join communities restoring mangroves, seagrass and saltmarsh to secure nature-based carbon savings and local livelihoods.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 230),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Secondary: Login
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        BlockZenLoginScreen.routeName,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 46),
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Primary: Get Started
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, HomeScreen.routeName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: themePrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 6,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: themePrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Small footer / accessibility hint
                Text(
                  'By continuing you agree to our Terms & Privacy',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 179),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
