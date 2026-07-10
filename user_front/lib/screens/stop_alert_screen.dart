import 'package:flutter/material.dart';

import 'arrival_screen.dart';

class StopAlertScreen extends StatelessWidget {
  const StopAlertScreen({super.key});

  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Column(
            children: [
              const _TopControls(),
              const Spacer(flex: 2),
              InkResponse(
                onTap: () => _showArrival(context),
                radius: 76,
                child: Container(
                  width: 145,
                  height: 145,
                  decoration: const BoxDecoration(
                    color: _yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: _navy,
                    size: 82,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Atención',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Estás a 1 paradero de tu\ndestino: PARADERO AVIACIÓN',
                textAlign: TextAlign.center,
                style: _bodyStyle,
              ),
              const SizedBox(height: 24),
              const Text(
                'Acércate a la puerta\nde bajada.',
                textAlign: TextAlign.center,
                style: _bodyStyle,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: () => _showArrival(context),
                  child: const Text(
                    'SIMULAR LLEGADA',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArrival(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ArrivalScreen()),
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
          onPressed: () {},
          tooltip: 'Configuración',
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
    );
  }
}

const _bodyStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  height: 1.4,
  fontWeight: FontWeight.w600,
);
