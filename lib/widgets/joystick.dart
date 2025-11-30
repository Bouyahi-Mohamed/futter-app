import 'dart:math';
import 'package:flutter/material.dart';

class VirtualJoystick extends StatefulWidget {
  final void Function(Offset) onChange;
  final double size;
  final double knobSize;
  final Color baseColor;
  final Color knobColor;

  const VirtualJoystick({
    super.key,
    required this.onChange,
    this.size = 150,
    this.knobSize = 50,
    this.baseColor = const Color(0x88FFFFFF),
    this.knobColor = Colors.blue,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;

  void _updatePosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final offset = localPosition - center;
    final distance = offset.distance;
    final radius = (widget.size - widget.knobSize) / 2;

    Offset normalizedOffset;
    if (distance <= radius) {
      _knobPosition = offset;
      normalizedOffset = offset / radius;
    } else {
      final angle = offset.direction;
      _knobPosition = Offset.fromDirection(angle, radius);
      normalizedOffset = Offset.fromDirection(angle, 1.0);
    }

    setState(() {});
    widget.onChange(normalizedOffset);
  }

  void _resetPosition() {
    setState(() {
      _knobPosition = Offset.zero;
    });
    widget.onChange(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (details) => _updatePosition(details.localPosition),
        onPanUpdate: (details) => _updatePosition(details.localPosition),
        onPanEnd: (_) => _resetPosition(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.baseColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 2),
              ),
            ),
            // Knob
            Transform.translate(
              offset: _knobPosition,
              child: Container(
                width: widget.knobSize,
                height: widget.knobSize,
                decoration: BoxDecoration(
                  color: widget.knobColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
