import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';
import '../../../widgets/joystick.dart';
import '../../../config/trash_icons.dart';
import '../../../widgets/game_health_bar.dart';

class OceanLevelScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OceanLevelScreen({super.key, this.onComplete});

  @override
  State<OceanLevelScreen> createState() => _OceanLevelScreenState();
}

class _OceanLevelScreenState extends State<OceanLevelScreen>
    with TickerProviderStateMixin {
  // Game State
  int _plasticCleaned = 0;
  int _creaturesFreed = 0;
  final int _plasticGoal = 30;
  final int _creaturesGoal = 5; // Increased goal
  int _oxygen = 100;
  bool _isPlaying = false;
  bool _isGameEnding = false;
  Timer? _gameTimer; // Unused, can be removed or kept for future
  Timer? _oxygenTimer; // Game logic (oxygen drain)
  Timer? _gameLoopTimer; // Physics loop

  // Physics & Movement
  double _characterX = 100;
  double _characterY = 200;
  Offset _moveVector = Offset.zero;
  double _moveSpeed = 8.0;
  double _worldWidth = 2000; // Expanded world
  double _worldHeight = 600;

  // Camera
  double _cameraX = 0;

  final List<_OceanTrash> _trashItems = [];
  final List<_SeaCreature> _creatures = [];
  final Random _random = Random();

  late AnimationController _fishController;
  late AnimationController _coralController;

  @override
  void initState() {
    super.initState();
    _initializeLevel();

    _fishController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _coralController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Game Loop
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isPlaying) {
        try {
          _updateGameLoop();
        } catch (e) {
          debugPrint('Game Loop Error: $e');
        }
      }
    });
  }

  void _initializeLevel() {
    _trashItems.clear();
    _creatures.clear();

    // Spawn trash across the expanded world
    for (int i = 0; i < 40; i++) {
      _trashItems.add(_OceanTrash(
        x: 200 + _random.nextDouble() * (_worldWidth - 300),
        y: 50 + _random.nextDouble() * (_worldHeight - 100),
        type: TrashType.values[_random.nextInt(TrashType.values.length)],
      ));
    }

    // Spawn trapped creatures
    for (int i = 0; i < 8; i++) {
      String type = ['turtle', 'dolphin', 'fish'][_random.nextInt(3)];
      _creatures.add(_SeaCreature(
        x: 400 + _random.nextDouble() * (_worldWidth - 500),
        y: 100 + _random.nextDouble() * (_worldHeight - 200),
        type: type,
        trapped: true,
      ));
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameEnding = false;
      _oxygen = 100;
      _plasticCleaned = 0;
      _creaturesFreed = 0;
      _characterX = 100;
      _characterY = 200;
      _moveVector = Offset.zero;
      
      // Reset creatures
      for (var creature in _creatures) {
        creature.trapped = true;
      }
      
      // Re-spawn trash if needed or just reset (simplified: keep existing layout)
      if (_trashItems.isEmpty) _initializeLevel();
    });

    _oxygenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) return;
      setState(() {
        if (_oxygen > 0) {
          _oxygen -= 1; // Slower drain
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
        _characterY += _moveVector.dy * _moveSpeed;

        // Clamp
        _characterX = _characterX.clamp(0, _worldWidth);
        _characterY = _characterY.clamp(0, _worldHeight);
      }

      // Camera Follow
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      
      _cameraX = (_characterX - screenWidth / 2).clamp(0, _worldWidth - screenWidth);
      if (_cameraX < 0) _cameraX = 0;

      // Interactions
      _checkInteractions();
    });
  }

  void _checkInteractions() {
    // Check trash collection
    _trashItems.removeWhere((trash) {
      if ((_characterX - trash.x).abs() < 40 && (_characterY - trash.y).abs() < 40) {
        _plasticCleaned++;
        _showFeedback('🗑️ +1', Colors.green);
        _checkMissionComplete();
        return true;
      }
      return false;
    });

    // Check creature rescue
    for (var creature in _creatures) {
      if (creature.trapped &&
          (_characterX - creature.x).abs() < 50 &&
          (_characterY - creature.y).abs() < 50) {
        setState(() {
          creature.trapped = false;
          _creaturesFreed++;
          _oxygen = (_oxygen + 15).clamp(0, 100); // Bonus oxygen
          _showFeedback('❤️ تم الإنقاذ!', Colors.pink);
          _checkMissionComplete();
        });
      }
    }
  }

  void _checkMissionComplete() {
    if (!_isGameEnding && _plasticCleaned >= _plasticGoal && _creaturesFreed >= _creaturesGoal) {
      _isGameEnding = true;
      Future.delayed(const Duration(milliseconds: 500), () => _endGame(true));
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endGame(bool success) {
    _oxygenTimer?.cancel();
    setState(() => _isPlaying = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 مهمة مكتملة!' : '💨 نفذ الأكسجين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نفايات مجمعة: $_plasticCleaned / $_plasticGoal'),
            Text('كائنات محررة: $_creaturesFreed / $_creaturesGoal'),
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
    _oxygenTimer?.cancel();
    _gameTimer?.cancel();
    _gameLoopTimer?.cancel();
    _fishController.dispose();
    _coralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحار النظيفة 🌊'),
        backgroundColor: Colors.blue[800],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[400]!, Colors.blue[800]!, Colors.indigo[900]!],
              ),
            ),
          ),

          // Background Elements (Fish) - Parallax/Scrolling
          AnimatedBuilder(
            animation: _fishController,
            builder: (context, child) {
              return Stack(
                children: List.generate(5, (index) {
                  // Simple parallax: move them based on camera too
                  double parallaxX = (_fishController.value * _worldWidth + index * 300) % _worldWidth;
                  return Positioned(
                    left: parallaxX - _cameraX * 0.5, // Parallax
                    top: 100 + index * 100 + sin(_fishController.value * 2 * pi) * 30,
                    child: Opacity(
                      opacity: 0.6,
                      child: Icon(Icons.set_meal, color: Colors.white, size: 20 + index * 5.0),
                    ),
                  );
                }),
              );
            },
          ),

          // Coral Reef (Bottom) - Scrolls with world
          Positioned(
            bottom: 0,
            left: -_cameraX,
            width: _worldWidth,
            height: 100,
            child: CustomPaint(
              painter: _CoralPainter(_coralController.value, _worldWidth),
            ),
          ),

          // Trash Items
          ..._trashItems.map((trash) => Positioned(
            left: trash.x - _cameraX,
            top: trash.y,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  ModernTrashIcons.icons[trash.type] ?? '🗑️',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          )),

          // Sea Creatures
          ..._creatures.where((c) => c.trapped).map((creature) => Positioned(
            left: creature.x - _cameraX,
            top: creature.y,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  creature.type == 'turtle' ? Icons.pets :
                  creature.type == 'dolphin' ? Icons.water : Icons.set_meal,
                  color: Colors.greenAccent,
                  size: 40,
                ),
                // Net/Trap overlay
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.7), width: 2),
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 20),
                ),
              ],
            ),
          )),

          // Character
          if (_isPlaying)
            Positioned(
              left: _characterX - _cameraX,
              top: _characterY,
              child: Transform.scale(
                scaleX: _moveVector.dx < 0 ? -1 : 1, // Flip if moving left
                child: const CharacterAnimator(
                  isWalking: true,
                  size: 70,
                  outfit: CharacterOutfit.underwater,
                  isWoman: true,
                ),
              ),
            ),

          // UI / HUD
          if (!_isPlaying)
            _buildStartScreen()
          else
            Stack(
              fit: StackFit.expand,
              children: [
                // Stats (ignore pointer so they don't block game view)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: IgnorePointer(
                    child: Column(
                      children: [
                        GameHealthBar(currentHealth: _oxygen, maxHealth: 100),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delete_outline, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('$_plasticCleaned/$_plasticGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 20),
                              const Icon(Icons.pets, color: Colors.pinkAccent),
                              const SizedBox(width: 8),
                              Text('$_creaturesFreed/$_creaturesGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Joystick (interactive)
                Positioned(
                  bottom: 30,
                  left: 30,
                  child: VirtualJoystick(
                    size: 120,
                    onChange: (vector) {
                      setState(() => _moveVector = vector);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌊 البحار النظيفة',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildMissionItem(Icons.delete_outline, 'اجمع $_plasticGoal قطعة نفايات', Colors.blue),
            _buildMissionItem(Icons.pets, 'حرر $_creaturesGoal كائنات بحرية', Colors.pink),
            const SizedBox(height: 10),
            const Text('⚠️ حافظ على مستوى الأكسجين!', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('غطس'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _OceanTrash {
  final double x, y;
  final TrashType type;
  _OceanTrash({required this.x, required this.y, required this.type});
}

class _SeaCreature {
  final double x, y;
  final String type;
  bool trapped;
  _SeaCreature({required this.x, required this.y, required this.type, required this.trapped});
}

class _CoralPainter extends CustomPainter {
  final double animationValue;
  final double width;
  _CoralPainter(this.animationValue, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw coral across the entire width
    int count = (width / 40).ceil();
    for (int i = 0; i < count; i++) {
      final x = i * 40.0;
      // Randomize height slightly based on index
      final baseHeight = 40.0 + (i % 3) * 20;
      final height = baseHeight + sin(animationValue * pi + i) * 10;
      
      final path = Path();
      path.moveTo(x, size.height);
      path.quadraticBezierTo(x + 10, size.height - height, x + 20, size.height - height + 10);
      path.quadraticBezierTo(x + 30, size.height - height - 10, x + 40, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
