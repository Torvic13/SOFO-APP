import 'dart:async';

import 'package:flutter/material.dart';

import 'stop_alert_screen.dart';

class TravelingScreen extends StatefulWidget {
  const TravelingScreen({super.key});

  @override
  State<TravelingScreen> createState() => _TravelingScreenState();
}

class _TravelingScreenState extends State<TravelingScreen>
    with SingleTickerProviderStateMixin {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);

  late final AnimationController _controller;
  Timer? _arrivalTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _arrivalTimer = Timer(const Duration(seconds: 10), _showStopAlert);
  }

  void _showStopAlert() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const StopAlertScreen()),
    );
  }

  @override
  void dispose() {
    _arrivalTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'VIAJE EN CURSO',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Corredor 201',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const Spacer(),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          (_controller.value - .5) *
                              (constraints.maxWidth * .65),
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.directions_bus_filled,
                      color: Colors.white,
                      size: 125,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white38, thickness: 3),
              const Spacer(),
              const Text(
                'Destino: PARADERO AVIACIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Te avisaremos antes de llegar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 17),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
