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

class _BreathingSessionState extends State<BreathingSession> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    final total = widget.durationSeconds;
    
    // Timer principal (controla o tempo total da sessão)
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
    
    // Animação de pulsação (10 segundos: 5s crescendo + 5s diminuindo)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _pulseCtrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, _pulseCtrl]),
      builder: (context, child) {
        // Usar _pulseCtrl para calcular a pulsação (0..1 em 10 segundos)
        final pulseValue = _pulseCtrl.value; // 0..1
        // Pulsação: 0->1 (crescendo) 0->1 (diminuindo)
        // Usar seno para suavidade: cresce de 0->1 em π/2, diminui de 1->0 em π/2
        final wave = 0.5 + 0.5 * math.sin(2 * math.pi * pulseValue);
        final radius = 40 + 80 * wave;
        final opacity = (0.15 + 0.6 * wave).clamp(0.0, 1.0);
        
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Z pulsante
              Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withAlpha((0.6 * 255).round()),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha((opacity * 100).round()),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Z',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Mostrar tempo restante no formato MM:SS
              Builder(builder: (context) {
                final remaining = (widget.durationSeconds * (1 - _ctrl.value)).ceil();
                final minutes = (remaining ~/ 60).clamp(0, 60);
                final seconds = (remaining % 60).clamp(0, 59);
                final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                return Text(timeStr, style: textTheme.headlineSmall);
              }),
            ],
          ),
        );
      },
    );
  }
}
