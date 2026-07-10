import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class ArrivalScreen extends StatefulWidget {
  const ArrivalScreen({super.key});

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  static const _navy = Color(0xFF071426);
  static const _green = Color(0xFF42C857);

  Timer? _timer;
  int _secondsRemaining = 10;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _returnHome();
      }
    });
  }

  void _returnHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {},
                    tooltip: 'Configuración',
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
              ),
              const Spacer(flex: 2),
              Container(
                width: 145,
                height: 145,
                decoration: const BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 92),
              ),
              const SizedBox(height: 30),
              const Text(
                'Has llegado a tu\ndestino:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'PARADERO AVIACIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _green,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Gracias por usar la app.',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              const Spacer(flex: 2),
              Semantics(
                liveRegion: true,
                label: 'Regresando al inicio en $_secondsRemaining segundos',
                child: Text(
                  'Regresando al inicio en $_secondsRemaining segundos',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _secondsRemaining / 10,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  color: _green,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
