import 'package:flutter/material.dart';
import 'dart:math';

class GameHealthBar extends StatefulWidget {
  final int currentHealth;
  final int maxHealth;

  const GameHealthBar({
    super.key,
    required this.currentHealth,
    required this.maxHealth,
  });

  @override
  State<GameHealthBar> createState() => _GameHealthBarState();
}

class _GameHealthBarState extends State<GameHealthBar> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int _prevHealth = 0;

  @override
  void initState() {
    super.initState();
    _prevHealth = widget.currentHealth;
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);
  }

  @override
  void didUpdateWidget(GameHealthBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentHealth < _prevHealth) {
      _shakeController.forward(from: 0);
    }
    _prevHealth = widget.currentHealth;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Color _getHealthColor(double percentage) {
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = (widget.currentHealth / widget.maxHealth).clamp(0.0, 1.0);
    final Color color = _getHealthColor(percentage);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = sin(_shakeController.value * pi * 4) * 5;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                // Heart Icon with Pulse
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: percentage < 0.3 ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: const Icon(Icons.favorite, color: Colors.red, size: 24),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Progress Bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 15,
                      child: Stack(
                        children: [
                          // Background
                          Container(color: Colors.grey[800]),
                          // Fill
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 160 * percentage, // Approx width based on container
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withOpacity(0.6), color],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                          // Glare/Shine
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 5,
                            child: Container(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
