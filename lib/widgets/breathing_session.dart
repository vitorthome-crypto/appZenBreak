import 'package:flutter/material.dart';

class BreathingSession extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onFinished;
  final VoidCallback? onCancel;

  const BreathingSession({super.key, this.durationSeconds = 120, this.onFinished, this.onCancel});

  @override
  State<BreathingSession> createState() => _BreathingSessionState();
}

class _BreathingSessionState extends State<BreathingSession> with TickerProviderStateMixin {
  late final AnimationController _progressCtrl; // controls overall session progress (0..1)
  late final AnimationController _pulseCtrl; // controls expand/retract pulse (repeat reverse)
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    final total = widget.durationSeconds;
    // progress controller for the session length
    _progressCtrl = AnimationController(vsync: this, duration: Duration(seconds: total));
    _progressCtrl.forward();
    _progressCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinished?.call();
    });

    // pulse controller: expand 5s, retract 5s -> repeat(reverse:true)
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressCtrl, _pulseCtrl]),
      builder: (context, child) {
        final progress = _progressCtrl.value; // 0..1
        final pulse = _pulse.value; // 0..1
        // radius range matches previous visual: min 40, max 120
        final minRadius = 40.0;
        final maxRadius = 120.0;
        final radius = minRadius + (maxRadius - minRadius) * pulse;

        final remaining = (widget.durationSeconds * (1 - progress)).ceil();
        final minutes = (remaining ~/ 60).clamp(0, 60);
        final seconds = (remaining % 60).clamp(0, 59);
        final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        // Circle with app name centered
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).round()),
                    ),
                  ),
                  // App name inside circle
                  Text('ZenBreak', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(timeStr, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  // Mostrar botão de cancelar enquanto a sessão estiver rodando
                  if (_progressCtrl.isAnimating)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                      onPressed: () {
                        _progressCtrl.stop();
                        _pulseCtrl.stop();
                        widget.onCancel?.call();
                      },
                      child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
