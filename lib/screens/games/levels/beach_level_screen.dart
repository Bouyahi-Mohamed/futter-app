import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';

class BeachLevelScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const BeachLevelScreen({super.key, this.onComplete});

  @override
  State<BeachLevelScreen> createState() => _BeachLevelScreenState();
}

class _BeachLevelScreenState extends State<BeachLevelScreen>
    with TickerProviderStateMixin {
  int _plasticCollected = 0;
  final int _plasticGoal = 50;
  int _timeLeft = 120; // 2 minutes
  bool _isPlaying = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;

  double _characterX = 300;
  final List<_Plastic> _plasticItems = [];
  final List<_Wave> _waves = [];
  final Random _random = Random();

  late AnimationController _waveController;
  late AnimationController _birdController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _birdController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = 120;
      _plasticCollected = 0;
      _plasticItems.clear();
      _waves.clear();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _updateWaves();
        } else {
          _endGame(false);
        }
      });
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      _spawnPlastic();
      if (_random.nextInt(10) < 3) _spawnWave();
    });
  }

  void _spawnPlastic() {
    setState(() {
      _plasticItems.add(_Plastic(
        x: _random.nextDouble() * 600,
        y: 50 + _random.nextDouble() * 300,
        type: _random.nextInt(3),
      ));
    });
  }

  void _spawnWave() {
    setState(() {
      _waves.add(_Wave(x: -50, y: 350 + _random.nextDouble() * 50));
    });
  }

  void _updateWaves() {
    setState(() {
      _waves.removeWhere((wave) => wave.x > 700);
      for (var wave in _waves) {
        wave.x += 5;
        // Check collision with character
        if ((wave.x - _characterX).abs() < 40 && wave.y > 300) {
          _characterX = (_characterX - 30).clamp(50, 650);
        }
      }
    });
  }

  void _collectPlastic(_Plastic plastic) {
    if ((plastic.x - _characterX).abs() < 50) {
      setState(() {
        _plasticItems.remove(plastic);
        _plasticCollected++;
        if (_plasticCollected >= _plasticGoal) {
          _endGame(true);
        }
      });
    }
  }

  void _moveCharacter(double delta) {
    setState(() {
      _characterX = (_characterX + delta).clamp(50, 650);
    });
  }

  void _endGame(bool success) {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() => _isPlaying = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 مهمة مكتملة!' : '⏱️ انتهى الوقت'),
        content: Text('بلاستيك مجموع: $_plasticCollected / $_plasticGoal'),
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
    _spawnTimer?.cancel();
    _waveController.dispose();
    _birdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشاطئ الملوث 🏖️'),
        backgroundColor: Colors.blue[600],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue[200]!, Colors.blue[100]!, Colors.yellow[100]!],
              ),
            ),
          ),

          // Animated waves
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _OceanWavesPainter(_waveController.value),
              );
            },
          ),

          // Flying birds
          AnimatedBuilder(
            animation: _birdController,
            builder: (context, child) {
              return Positioned(
                left: _birdController.value * MediaQuery.of(context).size.width,
                top: 50,
                child: const Icon(Icons.flight, color: Colors.black54, size: 30),
              );
            },
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'الشاطئ الملوث',
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
                        Text('🗑️ جمع $_plasticGoal قطعة بلاستيك'),
                        const SizedBox(height: 10),
                        const Text('التحدي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('تجنب الأمواج العالية'),
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
                  child: GestureDetector(
                    onTap: () => _collectPlastic(plastic),
                    child: Icon(
                      [Icons.local_drink, Icons.shopping_bag, Icons.delete][plastic.type],
                      color: Colors.red[400],
                      size: 30,
                    ),
                  ),
                )),

                // Waves
                ..._waves.map((wave) => Positioned(
                  left: wave.x,
                  top: wave.y,
                  child: Icon(Icons.water, color: Colors.blue[300], size: 40),
                )),

                // Character
                Positioned(
                  left: _characterX,
                  bottom: 100,
                  child: const CharacterAnimator(
                    isWalking: true,
                    size: 60,
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
                    Text('🗑️ $_plasticCollected/$_plasticGoal', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
                  ElevatedButton(
                    onPressed: () => _moveCharacter(-30),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.arrow_back, size: 32),
                  ),
                  ElevatedButton(
                    onPressed: () => _moveCharacter(30),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.arrow_forward, size: 32),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Plastic {
  double x, y;
  int type;
  _Plastic({required this.x, required this.y, required this.type});
}

class _Wave {
  double x, y;
  _Wave({required this.x, required this.y});
}

class _OceanWavesPainter extends CustomPainter {
  final double animationValue;
  _OceanWavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i += 20) {
      final offset = 20 * sin((i / 50) + (animationValue * 2 * pi));
      path.lineTo(i, size.height * 0.7 + offset);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
