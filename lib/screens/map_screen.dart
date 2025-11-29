import 'package:flutter/material.dart';
import '../widgets/character_animator.dart';
import 'games/hero_game_screen.dart';
import 'games/climate_game_screen.dart';
import 'games/city_game_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Current level unlocked (1 to 7)
  int _currentLevel = 1;
  final ScrollController _scrollController = ScrollController();

  final List<_MapLevel> _levels = [
    _MapLevel(
      id: 7,
      title: 'القمة العالمية',
      description: 'ذروة الإنجاز البيئي',
      color: Colors.white,
      icon: Icons.flag,
      top: 50,
      left: 0.5, // Center
    ),
    _MapLevel(
      id: 6,
      title: 'المدن المستدامة',
      description: 'تحدي المدينة المستدامة',
      color: Colors.grey,
      icon: Icons.location_city,
      top: 250,
      left: 0.7,
      gameRoute: const CityGameScreen(),
    ),
    _MapLevel(
      id: 5,
      title: 'مراكز القيادة',
      description: 'مكافحة تغير المناخ',
      color: Colors.blueGrey,
      icon: Icons.business,
      top: 450,
      left: 0.3,
      gameRoute: const ClimateGameScreen(),
    ),
    _MapLevel(
      id: 4,
      title: 'الغابات الاستوائية',
      description: 'البطل البيئي - الغابة',
      color: Colors.green,
      icon: Icons.forest,
      top: 650,
      left: 0.6,
      gameRoute: const HeroGameScreen(), // Placeholder for Forest stage
    ),
    _MapLevel(
      id: 3,
      title: 'المناطق الساحلية',
      description: 'البطل البيئي - الشاطئ',
      color: Colors.amber,
      icon: Icons.beach_access,
      top: 850,
      left: 0.4,
      gameRoute: const HeroGameScreen(), // Placeholder for Beach stage
    ),
    _MapLevel(
      id: 2,
      title: 'المحيطات والبحار',
      description: 'البطل البيئي - المحيط',
      color: Colors.blue,
      icon: Icons.water,
      top: 1050,
      left: 0.7,
      gameRoute: const HeroGameScreen(), // Placeholder for Ocean stage
    ),
    _MapLevel(
      id: 1,
      title: 'نقطة البداية',
      description: 'القرية الملوثة',
      color: Colors.brown,
      icon: Icons.home,
      top: 1250,
      left: 0.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Scroll to bottom to start at level 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _unlockNextLevel() {
    setState(() {
      if (_currentLevel < 7) {
        _currentLevel++;
        // Auto scroll up slightly
        double targetScroll = _scrollController.offset - 200;
        if (targetScroll < 0) targetScroll = 0;
        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة العالم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report), // Debug cheat
            onPressed: _unlockNextLevel,
            tooltip: 'فتح المستوى التالي (للاختبار)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: 1400, // Total map height
          child: Stack(
            children: [
              // Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE3F2FD), // Sky
                      Color(0xFFE8F5E9), // Land
                      Color(0xFFFFF3E0), // Sand
                    ],
                  ),
                ),
              ),

              // Path Lines (Simple connection)
              CustomPaint(
                size: const Size(double.infinity, 1400),
                painter: _PathPainter(_levels),
              ),

              // Levels
              ..._levels.map((level) {
                bool isUnlocked = level.id <= _currentLevel;
                return Positioned(
                  top: level.top,
                  left: MediaQuery.of(context).size.width * level.left - 40, // Center offset
                  child: GestureDetector(
                    onTap: () {
                      if (isUnlocked && level.gameRoute != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => level.gameRoute!),
                        ).then((_) {
                          // Logic to check if level completed could go here
                          // For now, we use the debug button or manual trigger
                        });
                      } else if (!isUnlocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('هذا المستوى مغلق حالياً')),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isUnlocked ? level.color : Colors.grey[400],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isUnlocked ? Colors.white : Colors.grey,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isUnlocked ? level.icon : Icons.lock,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            level.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              // Character
              // Positioned dynamically based on current level
              AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                top: _levels.firstWhere((l) => l.id == _currentLevel).top - 60,
                left: MediaQuery.of(context).size.width * _levels.firstWhere((l) => l.id == _currentLevel).left - 50,
                child: const CharacterAnimator(isWalking: true, size: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLevel {
  final int id;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final double top;
  final double left; // 0.0 to 1.0 relative to screen width
  final Widget? gameRoute;

  _MapLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.top,
    required this.left,
    this.gameRoute,
  });
}

class _PathPainter extends CustomPainter {
  final List<_MapLevel> levels;

  _PathPainter(this.levels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Sort levels by ID to draw path from 1 to 7
    final sortedLevels = List<_MapLevel>.from(levels)..sort((a, b) => a.id.compareTo(b.id));

    if (sortedLevels.isNotEmpty) {
      final first = sortedLevels.first;
      path.moveTo(size.width * first.left, first.top + 40);

      for (int i = 1; i < sortedLevels.length; i++) {
        final current = sortedLevels[i];
        path.lineTo(size.width * current.left, current.top + 40);
      }
    }

    // Dashed effect
    // canvas.drawPath(path, paint); // Solid line for now
    
    // Draw simple lines
    for (int i = 0; i < sortedLevels.length - 1; i++) {
      final p1 = Offset(size.width * sortedLevels[i].left, sortedLevels[i].top + 40);
      final p2 = Offset(size.width * sortedLevels[i+1].left, sortedLevels[i+1].top + 40);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
