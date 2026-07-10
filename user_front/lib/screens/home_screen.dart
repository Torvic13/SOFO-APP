import 'package:flutter/material.dart';

import 'location_confirmation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: .96, end: 1.04).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTrip(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LocationConfirmationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Stack(
            children: [
              const Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      '¡Hola!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Estoy aquí para\nguiarte en tu viaje.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Semantics(
                button: true,
                label: 'Iniciar viaje',
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: InkResponse(
                    onTap: () => _startTrip(context),
                    radius: 145,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: 275,
                          height: 275,
                          decoration: BoxDecoration(
                            color: _yellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _yellow.withValues(
                                  alpha: .22 +
                                      (_animationController.value * .18),
                                ),
                                blurRadius: 20 +
                                    (_animationController.value * 16),
                                spreadRadius: 2 +
                                    (_animationController.value * 6),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_walk,
                            color: _navy,
                            size: 120,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'INICIAR VIAJE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _navy,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
