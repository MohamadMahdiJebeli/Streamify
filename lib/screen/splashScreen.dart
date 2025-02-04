import 'package:flutter/material.dart';
import 'package:streamify/gen/assets.gen.dart';
import 'package:streamify/screen/linkScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // تنظیم کنترلر انیمیشن
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // تعریف انیمیشن‌ها
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color.fromRGBO(38, 50, 56, 1),
      end: Colors.amber.shade300,
    ).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );

    // شروع انیمیشن‌ها
    _controller.forward();

    // انتقال به صفحه اصلی پس از اتمام انیمیشن
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1500),
            pageBuilder: (_, __, ___) => const Linkscreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Background Glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.shade300.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      radius: 1.5,
                    ),
                  ),
                ),
              ),

              // Main Content
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Image.asset(
                    Assets.streamfiyNoBG.path,
                    color: _colorAnimation.value,
                  ),
                ),
              ),

              // Developer Info with Slide Animation
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Developed By",
                        style: TextStyle(
                          color: Colors.amber.shade300,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Image.asset(
                        "assets/MJ_NoBg.png",
                        scale: 50,
                        color: Colors.amber.shade300,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}