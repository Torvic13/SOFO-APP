import 'dart:async';

import 'package:flutter/material.dart';

import 'boarding_confirmation_screen.dart';

class CorridorTrackingScreen extends StatefulWidget {
  const CorridorTrackingScreen({super.key});

  @override
  State<CorridorTrackingScreen> createState() => _CorridorTrackingScreenState();
}

class _CorridorTrackingScreenState extends State<CorridorTrackingScreen> {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);

  Timer? _timer;
  int _stopsAway = 3;
  bool _confirmationOpened = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_stopsAway > 1) {
        setState(() => _stopsAway--);
      } else if (_stopsAway == 1) {
        setState(() => _stopsAway = 0);
        timer.cancel();
        _timer = Timer(const Duration(seconds: 2), _openBoardingConfirmation);
      }
    });
  }

  Future<void> _openBoardingConfirmation() async {
    if (!mounted || _confirmationOpened) return;
    setState(() => _confirmationOpened = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BoardingConfirmationScreen(),
      ),
    );
  }

  Future<void> _retryBoardingConfirmation() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BoardingConfirmationScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _status => _stopsAway == 0
      ? 'El corredor 201 se encuentra en tu paradero'
      : 'El corredor 201 está a $_stopsAway ${_stopsAway == 1 ? 'paradero' : 'paraderos'}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'CORREDOR 201',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  _stopsAway == 0
                      ? Icons.directions_bus_filled
                      : Icons.directions_bus,
                  key: ValueKey(_stopsAway),
                  color: _stopsAway == 0 ? _yellow : Colors.white,
                  size: 145,
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                liveRegion: true,
                label: _status,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    _status,
                    key: ValueKey(_stopsAway),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              if (_stopsAway == 0)
                _confirmationOpened
                    ? SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: _retryBoardingConfirmation,
                          style: FilledButton.styleFrom(
                            backgroundColor: _yellow,
                            foregroundColor: _navy,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('CONFIRMAR QUE SUBÍ'),
                        ),
                      )
                    : const Text(
                        'Verificando abordaje...',
                        style: TextStyle(color: _yellow, fontSize: 17),
                      )
              else
                const LinearProgressIndicator(
                  color: _yellow,
                  backgroundColor: Colors.white12,
                  minHeight: 7,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
