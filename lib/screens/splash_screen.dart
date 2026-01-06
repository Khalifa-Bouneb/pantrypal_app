import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const splashDuration = Duration(seconds: 5);

  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: splashDuration);

    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {});
        });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goNext();
      }
    });

    _controller.forward();
  }

  Future<void> _goNext() async {
    if (!mounted) return;

    try {
      final loggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;

      if (loggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Progress pill with WHITE loading fill
  Widget _buildProgressPill(BuildContext context) {
    final double progressValue = _progressAnimation.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22), // subtle background track
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressValue.clamp(0.0, 1.0),
            child: Container(
              color: Colors.white, // 🔥 white loading bar (your request)
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const RadialGradient(
      center: Alignment(-0.2, -0.6),
      radius: 1.2,
      colors: [Color(0xFFDFF5D9), Color(0xFF8BC34A), Color(0xFFDFF5D9)],
      stops: [0.0, 0.5, 1.0],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo badge
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/pantrypallogo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 72),

                // White progress bar
                _buildProgressPill(context),

                const SizedBox(height: 14),

                const Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black45,
                        offset: Offset(0, 1),
                      ),
                    ],
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
