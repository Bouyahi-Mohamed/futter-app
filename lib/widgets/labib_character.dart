import 'package:flutter/material.dart';
import 'dart:math' as math;

enum LabibExpression {
  happy,
  waving,
  celebrating,
  thinking,
  encouraging,
}

class LabibCharacter extends StatefulWidget {
  final double size;
  final LabibExpression expression;
  final bool animate;

  const LabibCharacter({
    super.key,
    this.size = 150,
    this.expression = LabibExpression.happy,
    this.animate = true,
  });

  @override
  State<LabibCharacter> createState() => _LabibCharacterState();
}

class _LabibCharacterState extends State<LabibCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LabibPainter(
            expression: widget.expression,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}

class _LabibPainter extends CustomPainter {
  final LabibExpression expression;
  final double animationValue;

  _LabibPainter({
    required this.expression,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Colors
    final greenPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;
    
    final darkGreenPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Body (main circle)
    canvas.drawCircle(
      center,
      size.width * 0.35,
      greenPaint,
    );

    // Ears (triangular)
    final earSize = size.width * 0.15;
    final earOffset = size.width * 0.25;
    
    // Left ear
    final leftEarPath = Path();
    leftEarPath.moveTo(center.dx - earOffset, center.dy - size.height * 0.3);
    leftEarPath.lineTo(center.dx - earOffset - earSize * 0.5, center.dy - size.height * 0.5 + math.sin(animationValue * math.pi) * 5);
    leftEarPath.lineTo(center.dx - earOffset + earSize * 0.5, center.dy - size.height * 0.5 + math.sin(animationValue * math.pi) * 5);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, darkGreenPaint);

    // Right ear
    final rightEarPath = Path();
    rightEarPath.moveTo(center.dx + earOffset, center.dy - size.height * 0.3);
    rightEarPath.lineTo(center.dx + earOffset - earSize * 0.5, center.dy - size.height * 0.5 + math.sin(animationValue * math.pi) * 5);
    rightEarPath.lineTo(center.dx + earOffset + earSize * 0.5, center.dy - size.height * 0.5 + math.sin(animationValue * math.pi) * 5);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, darkGreenPaint);

    // White face patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.05),
        width: size.width * 0.4,
        height: size.height * 0.35,
      ),
      whitePaint,
    );

    // Eyes
    final eyeY = center.dy - size.height * 0.05;
    final eyeSpacing = size.width * 0.12;
    final eyeSize = size.width * 0.08;

    // Left eye white
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing, eyeY),
      eyeSize,
      whitePaint,
    );
    // Left eye pupil
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing + eyeSize * 0.2, eyeY),
      eyeSize * 0.5,
      blackPaint,
    );

    // Right eye white
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing, eyeY),
      eyeSize,
      whitePaint,
    );
    // Right eye pupil
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing + eyeSize * 0.2, eyeY),
      eyeSize * 0.5,
      blackPaint,
    );

    // Nose (small black triangle)
    final nosePath = Path();
    final noseY = center.dy + size.height * 0.05;
    nosePath.moveTo(center.dx, noseY);
    nosePath.lineTo(center.dx - size.width * 0.03, noseY + size.height * 0.04);
    nosePath.lineTo(center.dx + size.width * 0.03, noseY + size.height * 0.04);
    nosePath.close();
    canvas.drawPath(nosePath, blackPaint);

    // Mouth (smile)
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(center.dx - size.width * 0.1, center.dy + size.height * 0.12);
    smilePath.quadraticBezierTo(
      center.dx,
      center.dy + size.height * 0.18,
      center.dx + size.width * 0.1,
      center.dy + size.height * 0.12,
    );
    canvas.drawPath(smilePath, smilePaint);

    // Tail (animated wag)
    final tailAngle = math.sin(animationValue * math.pi * 2) * 0.3;
    final tailPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx + size.width * 0.3, center.dy + size.height * 0.1);
    canvas.rotate(tailAngle);
    
    final tailPath = Path();
    tailPath.moveTo(0, 0);
    tailPath.quadraticBezierTo(
      size.width * 0.15, -size.height * 0.1,
      size.width * 0.2, -size.height * 0.2,
    );
    tailPath.lineTo(size.width * 0.18, -size.height * 0.18);
    tailPath.quadraticBezierTo(
      size.width * 0.13, -size.height * 0.08,
      0, 0,
    );
    canvas.drawPath(tailPath, tailPaint);
    canvas.restore();

    // Expression-specific features
    if (expression == LabibExpression.waving) {
      _drawWavingPaw(canvas, center, size, animationValue);
    } else if (expression == LabibExpression.celebrating) {
      _drawSparkles(canvas, center, size, animationValue);
    }
  }

  void _drawWavingPaw(Canvas canvas, Offset center, Size size, double animation) {
    final pawPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    final pawAngle = math.sin(animation * math.pi * 4) * 0.5;
    
    canvas.save();
    canvas.translate(center.dx - size.width * 0.4, center.dy);
    canvas.rotate(pawAngle);
    
    // Paw
    canvas.drawCircle(Offset(0, 0), size.width * 0.08, pawPaint);
    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, Offset center, Size size, double animation) {
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2 + animation * math.pi * 2;
      final radius = size.width * 0.5;
      final sparkleX = center.dx + math.cos(angle) * radius;
      final sparkleY = center.dy + math.sin(angle) * radius;
      
      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        size.width * 0.02,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
