import 'dart:async';

import 'package:flutter/material.dart';

import 'voice_destination_screen.dart';

class LocationConfirmationScreen extends StatefulWidget {
  const LocationConfirmationScreen({super.key});

  @override
  State<LocationConfirmationScreen> createState() =>
      _LocationConfirmationScreenState();
}

class _LocationConfirmationScreenState extends State<LocationConfirmationScreen>
    with TickerProviderStateMixin {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);

  Timer? _locationTimer;
  int _secondsRemaining = 10;
  int _updateCount = 0;
  late final AnimationController _animationController;
  late final AnimationController _refreshController;
  late final Animation<double> _scaleAnimation;
  bool _isUpdating = false;

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
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _locationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() {
          _secondsRemaining = 10;
          _updateCount++;
        });
        _showUpdateAnimation();
      }
    });
  }

  Future<void> _showUpdateAnimation() async {
    if (!mounted) return;
    setState(() => _isUpdating = true);
    await _refreshController.forward(from: 0);
    if (!mounted) return;
    setState(() => _isUpdating = false);
  }

  void _confirmLocation() {
    _locationTimer?.cancel();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VoiceDestinationScreen()),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Regresar',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Detectamos que estás en:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'PARADERO GUARDIA CIVIL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _yellow,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Semantics(
                  button: true,
                  label: 'Confirmar ubicación, Paradero Guardia Civil',
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: InkResponse(
                      onTap: _confirmLocation,
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
                            Icon(Icons.check, color: _navy, size: 120),
                            SizedBox(height: 8),
                            Text(
                              'CONFIRMAR\nUBICACIÓN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _navy,
                                fontSize: 20,
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
                bottom: 0,
                child: Semantics(
                  liveRegion: true,
                  label:
                      'La ubicación se actualizará en $_secondsRemaining segundos',
                  child: Column(
                    children: [
                      Text(
                        'Actualizando ubicación en $_secondsRemaining segundos',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _secondsRemaining / 10,
                          minHeight: 7,
                          color: _yellow,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        ),
                        child: _isUpdating
                            ? Row(
                                key: const ValueKey('updating'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RotationTransition(
                                    turns: _refreshController,
                                    child: const Icon(
                                      Icons.sync,
                                      color: _yellow,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Actualizando ubicación...',
                                    style: TextStyle(
                                      color: _yellow,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _updateCount == 0
                                    ? 'Esperando la próxima lectura de ubicación'
                                    : 'Ubicación actualizada $_updateCount ${_updateCount == 1 ? 'vez' : 'veces'}',
                                key: ValueKey(_updateCount),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
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
