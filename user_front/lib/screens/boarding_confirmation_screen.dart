import 'dart:async';

import 'package:flutter/material.dart';

import 'assigned_corridor_screen.dart';
import 'traveling_screen.dart';

class BoardingConfirmationScreen extends StatefulWidget {
  const BoardingConfirmationScreen({super.key});

  @override
  State<BoardingConfirmationScreen> createState() =>
      _BoardingConfirmationScreenState();
}

class _BoardingConfirmationScreenState extends State<BoardingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;
  int _secondsRemaining = 120;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: .96, end: 1.04).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _searchAnotherCorridor();
      }
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _confirmBoarding() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TravelingScreen()),
    );
  }

  void _searchAnotherCorridor() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AssignedCorridorScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
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
                top: 70,
                left: 0,
                right: 0,
                child: Text(
                  '¿Te encuentras dentro\ndel corredor 201?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: Semantics(
                  button: true,
                  label: 'Sí, estoy dentro del corredor 201',
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: InkResponse(
                      onTap: _confirmBoarding,
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
                                    alpha:
                                        .22 +
                                        (_animationController.value * .18),
                                  ),
                                  blurRadius:
                                      20 + (_animationController.value * 16),
                                  spreadRadius:
                                      2 + (_animationController.value * 6),
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
                              Icons.directions_bus_filled,
                              color: _navy,
                              size: 110,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'SÍ, ESTOY EN\nEL CORREDOR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _navy,
                                fontSize: 19,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Semantics(
                  liveRegion: true,
                  label: 'Tiempo para confirmar: $_secondsRemaining segundos',
                  child: Column(
                    children: [
                      const Text(
                        'Tiempo para confirmar',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formattedTime,
                        style: const TextStyle(
                          color: _yellow,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _secondsRemaining / 120,
                          minHeight: 7,
                          color: _yellow,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Si no confirmas, buscaremos otro corredor para ti.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          _timer?.cancel();
                          _searchAnotherCorridor();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('SIMULAR NO CONFIRMACIÓN'),
                      ),
                    ],
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
