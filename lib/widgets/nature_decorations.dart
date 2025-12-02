import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Floating leaves animation for background decoration
class FloatingLeaves extends StatefulWidget {
  final int leafCount;
  final double speed;

  const FloatingLeaves({
    super.key,
    this.leafCount = 10,
    this.speed = 1.0,
  });

  @override
  State<FloatingLeaves> createState() => _FloatingLeavesState();
}

class _FloatingLeavesState extends State<FloatingLeaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Leaf> _leaves;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: (20 / widget.speed).round()),
      vsync: this,
    )..repeat();

    _leaves = List.generate(
      widget.leafCount,
      (index) => _Leaf(
        startX: math.Random().nextDouble(),
        startY: math.Random().nextDouble(),
        size: 15 + math.Random().nextDouble() * 15,
        rotation: math.Random().nextDouble() * math.pi * 2,
        speed: 0.5 + math.Random().nextDouble() * 0.5,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _LeavesPainter(
            leaves: _leaves,
            animationValue: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _Leaf {
  final double startX;
  final double startY;
  final double size;
  final double rotation;
  final double speed;

  _Leaf({
    required this.startX,
    required this.startY,
    required this.size,
    required this.rotation,
    required this.speed,
  });
}

class _LeavesPainter extends CustomPainter {
  final List<_Leaf> leaves;
  final double animationValue;

  _LeavesPainter({
    required this.leaves,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var leaf in leaves) {
      final x = leaf.startX * size.width;
      final y = ((leaf.startY + animationValue * leaf.speed) % 1.0) * size.height;
      final wobble = math.sin(animationValue * math.pi * 4 + leaf.rotation) * 10;

      canvas.save();
      canvas.translate(x + wobble, y);
      canvas.rotate(leaf.rotation + animationValue * math.pi);

      // Draw leaf shape
      final leafPath = Path();
      leafPath.moveTo(0, -leaf.size / 2);
      leafPath.quadraticBezierTo(
        leaf.size / 2, -leaf.size / 4,
        leaf.size / 2, leaf.size / 4,
      );
      leafPath.quadraticBezierTo(
        leaf.size / 2, leaf.size / 2,
        0, leaf.size / 2,
      );
      leafPath.quadraticBezierTo(
        -leaf.size / 2, leaf.size / 2,
        -leaf.size / 2, leaf.size / 4,
      );
      leafPath.quadraticBezierTo(
        -leaf.size / 2, -leaf.size / 4,
        0, -leaf.size / 2,
      );
      leafPath.close();

      canvas.drawPath(leafPath, leafPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Speech bubble for Labib's encouraging messages
class LabibSpeechBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const LabibSpeechBubble({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '💬',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative nature icons (trees, flowers, etc.)
class NatureIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const NatureIcon({
    super.key,
    required this.icon,
    this.color = const Color(0xFF66BB6A),
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}

/// Animated cloud decoration
class CloudDecoration extends StatefulWidget {
  final double size;

  const CloudDecoration({
    super.key,
    this.size = 80,
  });

  @override
  State<CloudDecoration> createState() => _CloudDecorationState();
}

class _CloudDecorationState extends State<CloudDecoration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_controller.value * 10, 0),
          child: CustomPaint(
            size: Size(widget.size, widget.size * 0.6),
            painter: _CloudPainter(),
          ),
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw cloud using circles
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), size.width * 0.2, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), size.width * 0.25, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5), size.width * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
