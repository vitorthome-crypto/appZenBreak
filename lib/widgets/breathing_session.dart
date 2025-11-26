import 'dart:math' as math;
import 'package:flutter/material.dart';

class BreathingSession extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onFinished;
  final ValueChanged<int>? onTick;

  const BreathingSession({super.key, this.durationSeconds = 120, this.onFinished, this.onTick});

  @override
  State<BreathingSession> createState() => _BreathingSessionState();
}

class _BreathingSessionState extends State<BreathingSession> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    final total = widget.durationSeconds;
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: total));
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinished?.call();
    });
    // Notificar ticks com tempo restante (em segundos)
    _ctrl.addListener(() {
      final remaining = (widget.durationSeconds * (1 - _ctrl.value)).ceil();
      widget.onTick?.call(remaining);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value; // 0..1
        // Use a smooth sinusoidal wave for pulsing effect
        final wave = 0.5 + 0.5 * math.sin(2 * math.pi * t);
        final radius = 40 + 80 * wave;
        final opacity = (0.15 + 0.6 * wave).clamp(0.0, 1.0);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha((opacity * 255).round()),
                ),
              ),
              const SizedBox(height: 16),
              // Mostrar tempo restante no formato MM:SS
              Builder(builder: (context) {
                final remaining = (widget.durationSeconds * (1 - _ctrl.value)).ceil();
                final minutes = (remaining ~/ 60).clamp(0, 60);
                final seconds = (remaining % 60).clamp(0, 59);
                final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                return Text(timeStr, style: Theme.of(context).textTheme.headlineSmall);
              }),
            ],
          ),
        );
      },
    );
  }
}
