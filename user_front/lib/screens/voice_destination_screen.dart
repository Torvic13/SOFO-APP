import 'package:flutter/material.dart';

import 'assigned_corridor_screen.dart';

class VoiceDestinationScreen extends StatefulWidget {
  const VoiceDestinationScreen({super.key});

  @override
  State<VoiceDestinationScreen> createState() =>
      _VoiceDestinationScreenState();
}

class _VoiceDestinationScreenState extends State<VoiceDestinationScreen>
    with SingleTickerProviderStateMixin {

  static const _navy = Color(0xFF071426);

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

  void _openDestination(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AssignedCorridorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
              ),
              const Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Text(
                  '¿En qué paradero\ndeseas bajar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: InkResponse(
                  onTap: () => _openDestination(context),
                  radius: 145,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 275,
                        height: 275,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0B1C35),
                          border: Border.all(
                            color: const Color(0xFF51BFFF),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF47B8FF).withValues(
                                alpha: .25 +
                                    (_animationController.value * .25),
                              ),
                              blurRadius: 20 +
                                  (_animationController.value * 18),
                              spreadRadius: 3 +
                                  (_animationController.value * 7),
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    const Text(
                      'Escuchando...',
                      style: TextStyle(
                        color: Color(0xFF48B8FF),
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Di el nombre del\nparadero claramente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _openDestination(context),
                      child: const Text(
                        'SIMULAR DESTINO DETECTADO',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
