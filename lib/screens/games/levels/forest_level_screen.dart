import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';
import '../../../widgets/joystick.dart';
import '../../../widgets/game_health_bar.dart';

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
  final int _treesGoal = 10;
  final int _animalsGoal = 5;
  
  // Game State
  bool _isPlaying = false;
  int _timeLeft = 180; // 3 minutes
  int _health = 100;
  Timer? _gameTimer;
  
  // Character Physics (2.5D)
  double _characterX = 100;
  double _characterZ = 100; // Depth
  double _characterHeight = 0; // Jump height
  double _velocityY = 0;
  bool _isJumping = false;
  int _jumpCount = 0;
  double _moveSpeed = 5;
  Offset _moveVector = Offset.zero;
  
  // Camera
  double _scrollX = 0;
  final double _levelWidth = 3000;

  // Level Objects
  final List<_Animal> _animals = [];
  final List<_PlantingSpot> _plantingSpots = [];
  final List<_Obstacle> _obstacles = [];
  final Random _random = Random();
  
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

    // Game Loop
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isPlaying) _updateGameLoop();
    });
  }

  void _initializeLevel() {
    _animals.clear();
    _plantingSpots.clear();
    _obstacles.clear();

    // Create trapped animals (Spread over level width)
    for (int i = 0; i < 15; i++) {
      _animals.add(_Animal(
        x: _random.nextDouble() * (_levelWidth - 200) + 100,
        z: 50 + _random.nextDouble() * 200,
        type: ['bird', 'squirrel', 'rabbit', 'deer', 'fox'][_random.nextInt(5)],
        rescued: false,
      ));
    }
    
    // Create planting spots
    for (int i = 0; i < 25; i++) {
      _plantingSpots.add(_PlantingSpot(
        x: _random.nextDouble() * (_levelWidth - 200) + 100,
        z: 50 + _random.nextDouble() * 200,
        planted: false,
      ));
    }
    
    // Create obstacles
    for (int i = 0; i < 15; i++) {
      _obstacles.add(_Obstacle(
        x: _random.nextDouble() * (_levelWidth - 200) + 100,
        z: 50 + _random.nextDouble() * 200,
        type: _random.nextBool() ? 'fallen_trunk' : 'fire',
      ));
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = 180;
      _health = 100;
      _treesPlanted = 0;
      _animalsRescued = 0;
      _characterX = 100;
      _characterZ = 100;
      _characterHeight = 0;
      _scrollX = 0;
      _initializeLevel();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0 && _health > 0) {
          _timeLeft--;
        } else {
          _endGame(false);
        }
      });
    });
  }

  void _updateGameLoop() {
    setState(() {
      // Movement
      if (_moveVector != Offset.zero) {
        _characterX += _moveVector.dx * _moveSpeed;
        _characterZ -= _moveVector.dy * _moveSpeed;
        
        _characterX = _characterX.clamp(20, _levelWidth - 20);
        _characterZ = _characterZ.clamp(50, 250);
      }

      // Camera Follow
      double screenWidth = MediaQuery.of(context).size.width;
      double targetScrollX = _characterX - screenWidth / 2;
      _scrollX = targetScrollX.clamp(0, _levelWidth - screenWidth);

      // Jump Physics
      if (_isJumping || _characterHeight > 0) {
        _characterHeight += _velocityY;
        _velocityY -= 1.5;
        if (_characterHeight <= 0) {
          _characterHeight = 0;
          _isJumping = false;
          _velocityY = 0;
          _jumpCount = 0;
        }
      }

      // Check Interactions
      _checkInteractions();
    });
  }

  void _checkInteractions() {
    // Rescue Animals
    for (var animal in _animals) {
      if (!animal.rescued && 
          (animal.x - _characterX).abs() < 40 && 
          (animal.z - _characterZ).abs() < 30 &&
          _characterHeight < 20) {
        setState(() {
          animal.rescued = true;
          _animalsRescued++;
          _checkMissionComplete();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('أنقذت ${animal.type}! 🐾'), 
            duration: const Duration(milliseconds: 500),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    // Plant Trees
    for (var spot in _plantingSpots) {
      if (!spot.planted && 
          (spot.x - _characterX).abs() < 40 && 
          (spot.z - _characterZ).abs() < 30 &&
          _characterHeight < 20) {
        setState(() {
          spot.planted = true;
          _treesPlanted++;
          _checkMissionComplete();
        });
      }
    }

    // Obstacles (Damage)
    for (var obstacle in _obstacles) {
      if ((obstacle.x - _characterX).abs() < 40 && 
          (obstacle.z - _characterZ).abs() < 30 &&
          _characterHeight < 20) {
        if (_random.nextInt(20) == 0) { 
           setState(() {
             _health = (_health - 5).clamp(0, 100);
             _characterHeight += 20; // Knockback up
             if (_health <= 0) _endGame(false);
           });
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ احترس! (-5 صحة)'),
              duration: Duration(milliseconds: 300),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _checkMissionComplete() {
    if (_treesPlanted >= _treesGoal && _animalsRescued >= _animalsGoal) {
      Future.microtask(() => _endGame(true));
    }
  }

  void _jump() {
    if (_jumpCount < 2) {
      setState(() {
        _isJumping = true;
        _velocityY = 18;
        _jumpCount++;
      });
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
          // Background: Forest Floor
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[900]!, // Deep forest
                  Colors.brown[800]!, // Ground
                ],
              ),
            ),
          ),
          
          // Animated Sunlight Rays
          AnimatedBuilder(
            animation: _sunlightController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.2 + (_sunlightController.value * 0.1),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SunlightPainter(),
                ),
              );
            },
          ),

          if (!_isPlaying)
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
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('المهمة:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('🌱 زراعة $_treesGoal شجرة', style: const TextStyle(color: Colors.white)),
                        Text('🐾 إنقاذ $_animalsGoal حيوانات', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        const Text('التحكم:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('🕹️ تحرك للبحث عن أماكن الزراعة والحيوانات', style: const TextStyle(color: Colors.white)),
                        const Text('⬆️ اقفز لتجنب العقبات', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
                ],
              ),
            )
          else
            Stack(
              children: [
                // Planting Spots
                ..._plantingSpots.map((spot) => Positioned(
                  left: spot.x - _scrollX,
                  bottom: spot.z,
                  child: spot.planted 
                    ? const Icon(Icons.park, color: Colors.green, size: 40)
                    : Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.brown[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                )),

                // Animals
                ..._animals.map((animal) => Positioned(
                  left: animal.x - _scrollX,
                  bottom: animal.z,
                  child: !animal.rescued
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          animal.type == 'bird' ? Icons.flutter_dash : 
                          animal.type == 'squirrel' ? Icons.pets :
                          animal.type == 'rabbit' ? Icons.cruelty_free :
                          Icons.pest_control_rodent,
                          color: Colors.brown,
                          size: 30,
                        ),
                      )
                    : const SizedBox(),
                )),

                // Obstacles
                ..._obstacles.map((obs) => Positioned(
                  left: obs.x - _scrollX,
                  bottom: obs.z,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: obs.type == 'fire' ? Colors.red.withOpacity(0.2) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      obs.type == 'fallen_trunk' ? Icons.forest : Icons.local_fire_department,
                      color: obs.type == 'fallen_trunk' ? Colors.brown : Colors.red,
                      size: 40,
                    ),
                  ),
                )),

                // Character Shadow
                Positioned(
                  left: _characterX - _scrollX + 10,
                  bottom: _characterZ,
                  child: Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Character
                Positioned(
                  left: _characterX - _scrollX,
                  bottom: _characterZ + _characterHeight,
                  child: CharacterAnimator(
                    isWalking: _moveVector != Offset.zero,
                    size: 60,
                    outfit: CharacterOutfit.adventure,
                  ),
                ),

                // Falling Leaves
                IgnorePointer(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _FallingLeavesPainter(_leavesController.value),
                  ),
                ),
                
                // HUD
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      GameHealthBar(currentHealth: _health, maxHealth: 100),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('⏱️ $_timeLeft', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('🌱 $_treesPlanted/$_treesGoal', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('🐾 $_animalsRescued/$_animalsGoal', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls
                Positioned(
                  bottom: 30,
                  left: 30,
                  right: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      VirtualJoystick(
                        onChange: (vector) {
                          setState(() {
                            _moveVector = vector;
                          });
                        },
                      ),
                      GestureDetector(
                        onTapDown: (_) => _jump(),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_upward, size: 40, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Helper Classes
class _Animal {
  double x, z;
  String type;
  bool rescued;
  _Animal({required this.x, required this.z, required this.type, required this.rescued});
}

class _PlantingSpot {
  double x, z;
  bool planted;
  _PlantingSpot({required this.x, required this.z, required this.planted});
}

class _Obstacle {
  double x, z;
  String type;
  _Obstacle({required this.x, required this.z, required this.type});
}

// Custom Painters
class _SunlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.yellow.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.7, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FallingLeavesPainter extends CustomPainter {
  final double animationValue;
  _FallingLeavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final y = (startY + animationValue * size.height) % size.height;
      
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
