import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';

class OceanLevelScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OceanLevelScreen({super.key, this.onComplete});

  @override
  State<OceanLevelScreen> createState() => _OceanLevelScreenState();
}

class _OceanLevelScreenState extends State<OceanLevelScreen>
    with TickerProviderStateMixin {
  int _plasticCleaned = 0;
  int _creaturesFreed = 0;
  final int _plasticGoal = 30;
  final int _creaturesGoal = 3;
  int _oxygen = 100;
  bool _isPlaying = false;
  Timer? _gameTimer;
  Timer? _oxygenTimer;

  double _characterX = 300;
  double _characterY = 200;

  final List<_UnderwaterPlastic> _plasticItems = [];
  final List<_SeaCreature> _creatures = [];
  final Random _random = Random();

  late AnimationController _fishController;
  late AnimationController _coralController;

  @override
  void initState() {
    super.initState();
    _initializeLevel();

    _fishController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _coralController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _initializeLevel() {
    // Spawn plastic
    for (int i = 0; i < 30; i++) {
      _plasticItems.add(_UnderwaterPlastic(
        x: _random.nextDouble() * 650,
        y: 100 + _random.nextDouble() * 350,
        type: _random.nextInt(3),
      ));
    }

    // Spawn trapped creatures
    _creatures.addAll([
      _SeaCreature(x: 150, y: 200, type: 'turtle', trapped: true),
      _SeaCreature(x: 400, y: 300, type: 'dolphin', trapped: true),
      _SeaCreature(x: 550, y: 150, type: 'fish', trapped: true),
    ]);
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _oxygen = 100;
      _plasticCleaned = 0;
      _creaturesFreed = 0;
      _characterX = 300;
      _characterY = 200;

      for (var creature in _creatures) {
        creature.trapped = true;
      }
    });

    _oxygenTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        if (_oxygen > 0) {
          _oxygen -= 2;
        } else {
          _endGame(false);
        }
      });
    });
  }

  void _moveCharacter(String direction) {
    if (!_isPlaying) return;

    setState(() {
      if (direction == 'left') {
        _characterX = (_characterX - 25).clamp(50, 650);
      } else if (direction == 'right') {
        _characterX = (_characterX + 25).clamp(50, 650);
      } else if (direction == 'up') {
        _characterY = (_characterY - 25).clamp(50, 450);
      } else if (direction == 'down') {
        _characterY = (_characterY + 25).clamp(50, 450);
      }

      _checkInteractions();
    });
  }

  void _checkInteractions() {
    // Check plastic collection
    _plasticItems.removeWhere((plastic) {
      if ((_characterX - plastic.x).abs() < 30 && (_characterY - plastic.y).abs() < 30) {
        _plasticCleaned++;
        return true;
      }
      return false;
    });

    // Check creature rescue
    for (var creature in _creatures) {
      if (creature.trapped &&
          (_characterX - creature.x).abs() < 40 &&
          (_characterY - creature.y).abs() < 40) {
        setState(() {
          creature.trapped = false;
          _creaturesFreed++;
          _oxygen = (_oxygen + 10).clamp(0, 100); // Bonus oxygen
        });
      }
    }

    if (_plasticCleaned >= _plasticGoal && _creaturesFreed >= _creaturesGoal) {
      _endGame(true);
    }
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
            Text('بلاستيك منظف: $_plasticCleaned / $_plasticGoal'),
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
    _fishController.dispose();
    _coralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحار النظيفة 🌊'),
        backgroundColor: Colors.blue[900],
      ),
      body: Stack(
        children: [
          // Underwater background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[700]!, Colors.blue[900]!, Colors.indigo[900]!],
              ),
            ),
          ),

          // Animated coral
          AnimatedBuilder(
            animation: _coralController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 100),
                  painter: _CoralPainter(_coralController.value),
                ),
              );
            },
          ),

          // Swimming fish
          AnimatedBuilder(
            animation: _fishController,
            builder: (context, child) {
              return Positioned(
                left: _fishController.value * MediaQuery.of(context).size.width,
                top: 100 + sin(_fishController.value * 2 * pi) * 50,
                child: Icon(Icons.set_meal, color: Colors.orange[300], size: 30),
              );
            },
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'البحار النظيفة',
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
                        Text('🗑️ تنظيف $_plasticGoal قطعة بلاستيك'),
                        Text('🐢 تحرير $_creaturesGoal كائنات بحرية'),
                        const SizedBox(height: 10),
                        const Text('التحدي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('إدارة مستوى الأكسجين'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
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
                // Plastic items
                ..._plasticItems.map((plastic) => Positioned(
                  left: plastic.x,
                  top: plastic.y,
                  child: Icon(
                    [Icons.local_drink, Icons.shopping_bag, Icons.delete][plastic.type],
                    color: Colors.red[300],
                    size: 25,
                  ),
                )),

                // Trapped creatures
                ..._creatures.where((c) => c.trapped).map((creature) => Positioned(
                  left: creature.x,
                  top: creature.y,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        creature.type == 'turtle' ? Icons.pets :
                        creature.type == 'dolphin' ? Icons.water : Icons.set_meal,
                        color: Colors.green[300],
                        size: 40,
                      ),
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                    ],
                  ),
                )),

                // Character (diver)
                Positioned(
                  left: _characterX,
                  top: _characterY,
                  child: const CharacterAnimator(
                    isWalking: true,
                    size: 60,
                    outfit: CharacterOutfit.underwater,
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
                    Text('💨 O₂: $_oxygen%', style: TextStyle(color: _oxygen > 30 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    Text('🗑️ $_plasticCleaned/$_plasticGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('🐢 $_creaturesFreed/$_creaturesGoal', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(Icons.arrow_back, 'left'),
                  Column(
                    children: [
                      _buildControlButton(Icons.arrow_upward, 'up'),
                      const SizedBox(height: 10),
                      _buildControlButton(Icons.arrow_downward, 'down'),
                    ],
                  ),
                  _buildControlButton(Icons.arrow_forward, 'right'),
                ],
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
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.blue[700],
      ),
      child: Icon(icon, size: 24, color: Colors.white),
    );
  }
}

class _UnderwaterPlastic {
  final double x, y;
  final int type;
  _UnderwaterPlastic({required this.x, required this.y, required this.type});
}

class _SeaCreature {
  final double x, y;
  final String type;
  bool trapped;
  _SeaCreature({required this.x, required this.y, required this.type, required this.trapped});
}

class _CoralPainter extends CustomPainter {
  final double animationValue;
  _CoralPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final x = i * (size.width / 10);
      final height = 50 + animationValue * 10;
      canvas.drawOval(
        Rect.fromLTWH(x, size.height - height, 30, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
