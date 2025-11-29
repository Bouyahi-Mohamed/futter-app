import 'package:flutter/material.dart';
import '../../widgets/character_animator.dart';
import 'levels/beach_level_screen.dart';
import 'levels/forest_level_screen.dart';
import 'levels/city_level_screen.dart';
import 'levels/ocean_level_screen.dart';

class HeroGameMapScreen extends StatefulWidget {
  const HeroGameMapScreen({super.key});

  @override
  State<HeroGameMapScreen> createState() => _HeroGameMapScreenState();
}

class _HeroGameMapScreenState extends State<HeroGameMapScreen> {
  int _currentLevel = 1;
  final ScrollController _scrollController = ScrollController();

  final List<_LevelNode> _levels = [
    _LevelNode(
      id: 1,
      title: 'الشاطئ الملوث',
      subtitle: 'جمع 50 قطعة بلاستيك',
      icon: Icons.beach_access,
      color: Colors.blue[300]!,
      top: 0.7,
      left: 0.15,
      unlocked: true,
    ),
    _LevelNode(
      id: 2,
      title: 'الغابة المتدهورة',
      subtitle: 'زراعة 20 شجرة',
      icon: Icons.forest,
      color: Colors.green[600]!,
      top: 0.5,
      left: 0.4,
      unlocked: false,
    ),
    _LevelNode(
      id: 3,
      title: 'المدينة الإيكولوجية',
      subtitle: 'تركيب 10 ألواح شمسية',
      icon: Icons.location_city,
      color: Colors.grey[600]!,
      top: 0.3,
      left: 0.65,
      unlocked: false,
    ),
    _LevelNode(
      id: 4,
      title: 'البحار النظيفة',
      subtitle: 'تنظيف 30 قطعة بلاستيك',
      icon: Icons.scuba_diving,
      color: Colors.blue[800]!,
      top: 0.1,
      left: 0.85,
      unlocked: false,
    ),
  ];

  void _unlockNextLevel() {
    setState(() {
      if (_currentLevel < _levels.length) {
        _currentLevel++;
        _levels[_currentLevel - 1].unlocked = true;
      }
    });
  }

  void _navigateToLevel(_LevelNode level) {
    if (!level.unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل المستوى السابق أولاً!')),
      );
      return;
    }

    Widget? levelScreen;
    switch (level.id) {
      case 1:
        levelScreen = BeachLevelScreen(onComplete: _unlockNextLevel);
        break;
      case 2:
        levelScreen = ForestLevelScreen(onComplete: _unlockNextLevel);
        break;
      case 3:
        levelScreen = CityLevelScreen(onComplete: _unlockNextLevel);
        break;
      case 4:
        levelScreen = OceanLevelScreen(onComplete: _unlockNextLevel);
        break;
    }

    if (levelScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => levelScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة مغامرات البطل البيئي'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue[100]!,
                  Colors.green[100]!,
                  Colors.brown[100]!,
                ],
              ),
            ),
          ),

          // Decorative Background Elements
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 200),
              painter: _WavesPainter(),
            ),
          ),

          // Path connecting levels
          CustomPaint(
            size: Size.infinite,
            painter: _PathPainter(_levels),
          ),

          // Level Nodes
          ..._levels.map((level) {
            return Positioned(
              top: MediaQuery.of(context).size.height * level.top,
              left: MediaQuery.of(context).size.width * level.left - 60,
              child: GestureDetector(
                onTap: () => _navigateToLevel(level),
                child: Column(
                  children: [
                    // Level Node
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: level.unlocked ? level.color : Colors.grey[400],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: _currentLevel == level.id
                              ? Colors.yellow
                              : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            level.icon,
                            size: 50,
                            color: Colors.white,
                          ),
                          if (!level.unlocked)
                            const Icon(
                              Icons.lock,
                              size: 30,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Level Info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            level.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            level.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Character on current level
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height *
                    _levels.firstWhere((l) => l.id == _currentLevel).top -
                70,
            left: MediaQuery.of(context).size.width *
                    _levels.firstWhere((l) => l.id == _currentLevel).left -
                25,
            child: const CharacterAnimator(
              isWalking: true,
              size: 80,
              outfit: CharacterOutfit.adventure,
            ),
          ),

          // Progress Info
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التقدم',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('المستوى: $_currentLevel / ${_levels.length}'),
                ],
              ),
            ),
          ),

          // Debug unlock button (remove in production)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _unlockNextLevel,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.lock_open),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelNode {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double top;
  final double left;
  bool unlocked;

  _LevelNode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.top,
    required this.left,
    required this.unlocked,
  });
}

class _PathPainter extends CustomPainter {
  final List<_LevelNode> levels;
  _PathPainter(this.levels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.4)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < levels.length - 1; i++) {
      final start = Offset(
        size.width * levels[i].left,
        size.height * levels[i].top,
      );
      final end = Offset(
        size.width * levels[i + 1].left,
        size.height * levels[i + 1].top,
      );

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      }

      // Curved path
      final controlPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2 - 50,
      );
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    
    for (double i = 0; i <= size.width; i += 20) {
      path.lineTo(i, size.height * 0.5 + 10 * (i % 40 < 20 ? 1 : -1));
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
