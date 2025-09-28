import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_text.dart';
import 'home_screen_new.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Timings
  static const Duration _initialHold = Duration(seconds: 1);
  static const Duration _logoSlideDuration = Duration(milliseconds: 900);
  static const Duration _postAboutHold = Duration(
    seconds: 2,
  ); // wait 2s after about completes

  late final AnimationController _logoController;
  late final Animation<Offset> _logoOffset;
  late final Animation<double> _logoScale;
  late final Animation<double>
  _headerTopPadding; // will animate top padding to create space

  // Typing animation content (single sentence)
  final String _aboutText =
      'Revolutionizing Carbon Credit Management with Blockchain Technology';
  late String _displayAbout;
  Timer? _typingTimer;
  bool _showAbout = false;
  bool _skipped = false;

  // Typing config
  final Duration _typingInterval = const Duration(
    milliseconds: 40,
  ); // speed per tick

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _displayAbout = '';

    _logoController = AnimationController(
      duration: _logoSlideDuration,
      vsync: this,
    );

    // Slide from center (Offset.zero) up a modest amount but also animate scale and top padding
    _logoOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.22))
        .animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
        );

    // Slight scale down when moving up to emphasize "initializing" effect
    _logoScale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // We will animate a top padding value from center placement to a fixed top gap.
    // This is used to ensure the header block doesn't slide off-screen; instead it creates space below.
    _headerTopPadding = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Start after a small initial hold so animation feels like "initializing"
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(_initialHold);
    if (!mounted || _skipped) return;

    // Play header animation (scale + slide + padding) to "initialize" and create space for about
    await _logoController.forward();
    if (!mounted || _skipped) return;

    // Reveal about area
    setState(() => _showAbout = true);

    // Start typing animation (left-aligned)
    await _startTypingAnimation(); // waits until typing completes

    if (!mounted || _skipped) return;

    // After typing completes, wait an extra 2s then navigate
    await Future.delayed(_postAboutHold);
    if (!mounted || _skipped) return;

    if (mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  Future<void> _startTypingAnimation() async {
    _typingTimer?.cancel();

    final target = _aboutText;
    final length = target.length;
    int cursorPos = 0;
    final completer = Completer<void>();

    // Clear display
    setState(() {
      _displayAbout = '';
    });

    _typingTimer = Timer.periodic(_typingInterval, (timer) {
      if (!mounted) return;

      if (cursorPos < length) {
        setState(() {
          _displayAbout = _displayAbout + target[cursorPos];
        });
        cursorPos++;
        return;
      }

      // Completed
      _typingTimer?.cancel();
      _typingTimer = null;
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  void _skipIntro() {
    if (_skipped) return;
    _skipped = true;
    _logoController.stop();
    _typingTimer?.cancel();
    if (mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _logoController.stop();
      _typingTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logoController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _skipIntro,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D47A1),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              final topPadding =
                  _headerTopPadding.value + MediaQuery.of(context).padding.top;
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Header block: fixed height but visually moves upwards and scales.
                    // We use topPadding to make the header sit slightly below top after animation,
                    // creating a stable space below for the about text.
                    SizedBox(
                      height: h * 0.42,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, _logoOffset.value.dy * h * 0.15),
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo
                                  Container(
                                    width: w * 0.35,
                                    height: w * 0.35,
                                    constraints: const BoxConstraints(
                                      maxWidth: 180,
                                      maxHeight: 180,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 77,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      color: const Color(
                                                        0xFF0D47A1,
                                                      ),
                                                      size: w * 0.18,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: h * 0.03),

                                  // App name (centered)
                                  GradientText(
                                    text: 'NEELEDGER',
                                    style: GoogleFonts.poppins(
                                      fontSize: w * 0.055,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    colors: const [
                                      Color(0xFF40ffaa),
                                      Color(0xFF4079ff),
                                      Color(0xFF40ffaa),
                                      Color(0xFF4079ff),
                                      Color(0xFF40ffaa),
                                    ],
                                    animationSpeed: 8,
                                    showBorder: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // About / typing area: left-aligned, smaller font (reduced)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                        child: Align(
                          alignment: Alignment
                              .topLeft, // start typing from left-most screen
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                top: h * 0.02,
                                bottom: h * 0.04,
                              ),
                              child: Text(
                                _showAbout ? _displayAbout : '',
                                textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  fontSize: w * 0.028, // reduced font size
                                  color: Colors.grey[200],
                                  fontWeight: FontWeight.w600, // same weight
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // subtle skip hint
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 12.0, bottom: 18.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tap to skip',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}
