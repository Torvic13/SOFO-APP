import 'package:flutter/material.dart';

import 'corridor_tracking_screen.dart';

class AssignedCorridorScreen extends StatefulWidget {
  const AssignedCorridorScreen({super.key});

  @override
  State<AssignedCorridorScreen> createState() =>
      _AssignedCorridorScreenState();
}

class _AssignedCorridorScreenState extends State<AssignedCorridorScreen>
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

  void _confirmCorridor() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CorridorTrackingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
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
                child: Column(
                  children: [
                    Text(
                      'Para llegar a',
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'PARADERO AVIACIÓN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _yellow,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Tu corredor asignado es el 201',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Semantics(
                  button: true,
                  label: 'Confirmar espera del corredor 201',
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: InkResponse(
                      onTap: _confirmCorridor,
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
                            Icon(Icons.check, color: _navy, size: 120),
                            SizedBox(height: 8),
                            Text(
                              'CONFIRMAR\nESPERA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _navy,
                                fontSize: 21,
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
            ],
          ),
        ),
      ),
    );
  }
}
