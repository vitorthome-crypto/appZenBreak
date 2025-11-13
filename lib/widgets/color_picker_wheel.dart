import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorPickerWheel extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerWheel({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerWheel> createState() => _ColorPickerWheelState();
}

class _ColorPickerWheelState extends State<ColorPickerWheel> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hue wheel
        GestureDetector(
          onPanUpdate: (details) {
            final dx = details.localPosition.dx - 100;
            final dy = details.localPosition.dy - 100;
            final angle = (math.atan2(dy, dx) * 180 / math.pi + 360) % 360;
            setState(() {
              _hsv = _hsv.withHue(angle);
              widget.onColorChanged(_hsv.toColor());
            });
          },
          child: CustomPaint(
            painter: _HueWheelPainter(_hsv.hue),
            size: const Size(200, 200),
          ),
        ),
        const SizedBox(height: 16),
        // Saturation slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saturação: ${(_hsv.saturation * 100).toStringAsFixed(0)}%'),
            Slider(
              value: _hsv.saturation,
              onChanged: (v) {
                setState(() {
                  _hsv = _hsv.withSaturation(v);
                  widget.onColorChanged(_hsv.toColor());
                });
              },
            ),
          ],
        ),
        // Value (brightness) slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brilho: ${(_hsv.value * 100).toStringAsFixed(0)}%'),
            Slider(
              value: _hsv.value,
              onChanged: (v) {
                setState(() {
                  _hsv = _hsv.withValue(v);
                  widget.onColorChanged(_hsv.toColor());
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Preview + hex
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _hsv.toColor(),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Builder(builder: (context) {
          final color = _hsv.toColor();
          final r = (color.red * 255).toInt().toRadixString(16).padLeft(2, '0');
          final g = (color.green * 255).toInt().toRadixString(16).padLeft(2, '0');
          final b = (color.blue * 255).toInt().toRadixString(16).padLeft(2, '0');
          return Text(
            '#${(r + g + b).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        }),
      ],
    );
  }
}

class _HueWheelPainter extends CustomPainter {
  final double selectedHue;

  _HueWheelPainter(this.selectedHue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw hue wheel
    for (int i = 0; i < 360; i++) {
      final angle = i * math.pi / 180;
      final color = HSVColor.fromAHSV(1.0, i.toDouble(), 1.0, 1.0).toColor();
      final paint = Paint()..color = color;

      final startAngle = angle;
      final endAngle = (i + 1) * math.pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        paint,
      );
    }

    // Draw border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw selected hue indicator
    final indicatorAngle = selectedHue * math.pi / 180;
    final indicatorPos = Offset(
      center.dx + radius * math.cos(indicatorAngle),
      center.dy + radius * math.sin(indicatorAngle),
    );
    canvas.drawCircle(
      indicatorPos,
      8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      indicatorPos,
      8,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_HueWheelPainter oldDelegate) {
    return oldDelegate.selectedHue != selectedHue;
  }
}
