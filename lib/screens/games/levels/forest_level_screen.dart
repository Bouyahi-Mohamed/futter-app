import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';

class ForestLevelScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const ForestLevelScreen({super.key, this.onComplete});

  @override
  State<ForestLevelScreen> createState() => _ForestLevelScreenState();
}

class _ForestLevelScreenState extends State<ForestLevelScreen> with TickerProviderStateMixin {
  // Mission Progress
  int _treesPlanted = 0;
  int _animalsRescued = 0;
  final int _treesGoal = 20;
  final int _animalsGoal = 5;
  
  // Character Position
  double _characterX = 100;
  double _characterY = 400;
  bool _isJumping = false;
  
  // Game State
  bool _isPlaying = false;
  int _timeLeft = 180; // 3 minutes
  Timer? _gameTimer;
  
  // Level Objects
  final List<_Platform> _platforms = [];
  final List<_Animal> _trappedAnimals = [];
  final List<_PlantingSpot> _plantingSpots = [];
  final List<_Obstacle> _obstacles = [];
  
  // Animations
  late AnimationController _sunlightController;
  late AnimationController _leavesController;

  @override
  void initState() {
    super.initState();
    _initializeLevel();
    
    // Sunlight animation
    _sunlightController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Falling leaves animation
    _leavesController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  void _initializeLevel() {
    final random = Random();
    
    // Create tree platforms (multi-level)
    _platforms.addAll([
      _Platform(x: 50, y: 450, width: 150, height: 20, level: 0),
      _Platform(x: 250, y: 400, width: 120, height: 20, level: 1),
      _Platform(x: 450, y: 350, width: 140, height: 20, level: 2),
      _Platform(x: 100, y: 300, width: 130, height: 20, level: 2),
      _Platform(x: 300, y: 250, width: 150, height: 20, level: 3),
      _Platform(x: 500, y: 200, width: 120, height: 20, level: 4),
    ]);
    
    // Create trapped animals
    _trappedAnimals.addAll([
      _Animal(x: 270, y: 360, type: 'bird', rescued: false),
      _Animal(x: 470, y: 310, type: 'squirrel', rescued: false),
      _Animal(x: 120, y: 260, type: 'rabbit', rescued: false),
      _Animal(x: 320, y: 210, type: 'deer', rescued: false),
      _Animal(x: 520, y: 160, type: 'fox', rescued: false),
    ]);
    
    // Create planting spots
    for (var platform in _platforms) {
      if (random.nextBool()) {
        _plantingSpots.add(_PlantingSpot(
          x: platform.x + random.nextDouble() * (platform.width - 30),
          y: platform.y - 40,
          planted: false,
        ));
      }
    }
    
    // Create obstacles (fallen trunks, burned areas)
    _obstacles.addAll([
      _Obstacle(x: 200, y: 430, width: 80, height: 30, type: 'fallen_trunk'),
      _Obstacle(x: 400, y: 380, width: 60, height: 40, type: 'burned_area'),
      _Obstacle(x: 150, y: 280, width: 70, height: 35, type: 'fallen_trunk'),
    ]);
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = 180;
      _treesPlanted = 0;
      _animalsRescued = 0;
      _characterX = 100;
      _characterY = 400;
      
      // Reset level
      for (var animal in _trappedAnimals) {
        animal.rescued = false;
      }
      for (var spot in _plantingSpots) {
        spot.planted = false;
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _checkMissionComplete();
        } else {
          _endGame(false);
        }
      });
    });
  }

  void _moveCharacter(String direction) {
    if (!_isPlaying || _isJumping) return;
    
    setState(() {
      if (direction == 'left') {
        _characterX = (_characterX - 20).clamp(0, 600);
      } else if (direction == 'right') {
        _characterX = (_characterX + 20).clamp(0, 600);
      } else if (direction == 'jump') {
        _jump();
      }
      
      _checkInteractions();
    });
  }

  void _jump() {
    if (_isJumping) return;
    
    setState(() {
      _isJumping = true;
    });
    
    // Simple jump animation
    final startY = _characterY;
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _characterY = (startY - 80).clamp(0, 500);
      });
      
      Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _characterY = _findPlatformBelowOrGround();
          _isJumping = false;
          _checkInteractions();
        });
      });
    });
  }

  double _findPlatformBelowOrGround() {
    for (var platform in _platforms) {
      if (_characterX >= platform.x && 
          _characterX <= platform.x + platform.width &&
          _characterY < platform.y) {
        return platform.y - 50; // Character height offset
      }
    }
    return 400; // Ground level
  }

  void _checkInteractions() {
    // Check animal rescue
    for (var animal in _trappedAnimals) {
      if (!animal.rescued && 
          (_characterX - animal.x).abs() < 30 && 
          (_characterY - animal.y).abs() < 30) {
        setState(() {
          animal.rescued = true;
          _animalsRescued++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('أنقذت ${animal.type}! 🐾'), duration: const Duration(seconds: 1)),
        );
      }
    }
    
    // Check planting spots
    for (var spot in _plantingSpots) {
      if (!spot.planted && 
          (_characterX - spot.x).abs() < 30 && 
          (_characterY - spot.y).abs() < 30) {
        if (_treesPlanted < _treesGoal) {
          setState(() {
            spot.planted = true;
            _treesPlanted++;
          });
        }
      }
    }
  }

  void _checkMissionComplete() {
    if (_treesPlanted >= _treesGoal && _animalsRescued >= _animalsGoal) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 مهمة مكتملة!' : '⏱️ انتهى الوقت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أشجار مزروعة: $_treesPlanted / $_treesGoal'),
            Text('حيوانات منقذة: $_animalsRescued / $_animalsGoal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              if (success) widget.onComplete?.call();
            },
            child: const Text('خروج'),
          ),
          if (!success)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text('إعادة المحاولة'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _sunlightController.dispose();
    _leavesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الغابة المتدهورة 🌳'),
        backgroundColor: Colors.green[800],
      ),
      body: Stack(
        children: [
          // Background: Forest with sunlight
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[200]!,
                  Colors.green[400]!,
                  Colors.brown[300]!,
                ],
              ),
            ),
          ),
          
          // Animated Sunlight Rays
          AnimatedBuilder(
            animation: _sunlightController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + (_sunlightController.value * 0.2),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SunlightPainter(),
                ),
              );
            },
          ),
          
          // Falling Leaves
          AnimatedBuilder(
            animation: _leavesController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _FallingLeavesPainter(_leavesController.value),
              );
            },
          ),
          
          if (!_isPlaying)
            // Start Screen
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'الغابة المتدهورة',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('المهمة:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('🌱 زراعة $_treesGoal شجرة'),
                        Text('🐾 إنقاذ $_animalsGoal حيوانات'),
                        const SizedBox(height: 10),
                        const Text('التحدي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('التنقل بين platforms الأشجار'),
                        const Text('تجنب المناطق المحترقة والجذوع الساقطة'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            )
          else
            // Game Area
            Stack(
              children: [
                // Platforms (Tree branches)
                ..._platforms.map((platform) => Positioned(
                  left: platform.x,
                  top: platform.y,
                  child: Container(
                    width: platform.width,
                    height: platform.height,
                    decoration: BoxDecoration(
                      color: Colors.brown[700],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                      ],
                    ),
                  ),
                )),
                
                // Obstacles
                ..._obstacles.map((obstacle) => Positioned(
                  left: obstacle.x,
                  top: obstacle.y,
                  child: Container(
                    width: obstacle.width,
                    height: obstacle.height,
                    decoration: BoxDecoration(
                      color: obstacle.type == 'burned_area' ? Colors.black : Colors.brown[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        obstacle.type == 'burned_area' ? Icons.local_fire_department : Icons.landscape,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                )),
                
                // Planting Spots
                ..._plantingSpots.map((spot) => Positioned(
                  left: spot.x,
                  top: spot.y,
                  child: GestureDetector(
                    onTap: () {
                      if (!spot.planted && _treesPlanted < _treesGoal &&
                          (_characterX - spot.x).abs() < 50 && 
                          (_characterY - spot.y).abs() < 50) {
                        setState(() {
                          spot.planted = true;
                          _treesPlanted++;
                        });
                      }
                    },
                    child: Icon(
                      spot.planted ? Icons.park : Icons.circle,
                      color: spot.planted ? Colors.green : Colors.brown[300],
                      size: spot.planted ? 40 : 20,
                    ),
                  ),
                )),
                
                // Trapped Animals
                ..._trappedAnimals.where((a) => !a.rescued).map((animal) => Positioned(
                  left: animal.x,
                  top: animal.y,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Icon(Icons.pets, color: Colors.red, size: 24),
                  ),
                )),
                
                // Character
                Positioned(
                  left: _characterX,
                  top: _characterY,
                  child: CharacterAnimator(
                    isWalking: true,
                    size: 50,
                    outfit: CharacterOutfit.adventure,
                  ),
                ),
              ],
            ),
          
          // HUD
          if (_isPlaying)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('⏱️ $_timeLeft ث', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('🌱 $_treesPlanted/$_treesGoal', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('🐾 $_animalsRescued/$_animalsGoal', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          
          // Controls
          if (_isPlaying)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(Icons.arrow_back, 'left'),
                    _buildControlButton(Icons.arrow_upward, 'jump'),
                    _buildControlButton(Icons.arrow_forward, 'right'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String action) {
    return ElevatedButton(
      onPressed: () => _moveCharacter(action),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      child: Icon(icon, size: 32),
    );
  }
}

// Helper Classes
class _Platform {
  final double x, y, width, height;
  final int level;
  _Platform({required this.x, required this.y, required this.width, required this.height, required this.level});
}

class _Animal {
  final double x, y;
  final String type;
  bool rescued;
  _Animal({required this.x, required this.y, required this.type, required this.rescued});
}

class _PlantingSpot {
  final double x, y;
  bool planted;
  _PlantingSpot({required this.x, required this.y, required this.planted});
}

class _Obstacle {
  final double x, y, width, height;
  final String type;
  _Obstacle({required this.x, required this.y, required this.width, required this.height, required this.type});
}

// Custom Painters
class _SunlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // Draw sunlight rays
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * 150.0, 0, 50, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FallingLeavesPainter extends CustomPainter {
  final double animationValue;
  _FallingLeavesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.brown.withOpacity(0.5);
    final random = Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = (animationValue * size.height + i * 40) % size.height;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
