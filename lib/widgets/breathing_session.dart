import 'package:flutter/material.dart';

class BreathingSession extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onFinished;

  const BreathingSession({super.key, this.durationSeconds = 120, this.onFinished});

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
        final radius = 40 + 80 * (0.5 - (0.5 - (t - t.floorToDouble())).abs());
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).round()),
                ),
              ),
              const SizedBox(height: 16),
              Text('${(widget.durationSeconds * (1 - _ctrl.value)).ceil()}s', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        );
      },
    );
  }
}
