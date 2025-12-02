import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';
import '../../../widgets/joystick.dart';
import '../../../config/trash_icons.dart';
import '../../../widgets/game_health_bar.dart';

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
  int _health = 100;
  bool _isPlaying = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;

  // Character Physics (2.5D)
  double _characterX = 100;
  double _characterZ = 100; // Depth (Z-axis)
  double _characterHeight = 0; // Jump Height (Y-axis)
  double _velocityY = 0;
  bool _isJumping = false;
  int _jumpCount = 0;
  double _moveSpeed = 5; // Speed per frame
  bool _hasSpeedBoost = false;
  Offset _moveVector = Offset.zero; // From joystick

  // Environment
  late AnimationController _dayNightController;
  late AnimationController _rainController;
  bool _isRaining = false;
  Color _skyColor = Colors.lightBlue[200]!;

  final List<_Plastic> _plasticItems = [];
  final List<_Wave> _waves = [];
  final List<_Crab> _crabs = [];
  final List<_PowerUp> _powerUps = [];
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

    _dayNightController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _rainController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();

    _dayNightController.addListener(_updateSkyColor);
    
    Timer.periodic(const Duration(seconds: 20), (timer) {
      if (_isPlaying && _random.nextBool()) {
        setState(() => _isRaining = !_isRaining);
      }
    });
  }

  void _updateSkyColor() {
    final value = _dayNightController.value;
    setState(() {
      if (value < 0.25) {
        _skyColor = Color.lerp(Colors.blue[200], Colors.orange[300], value * 4)!;
      } else if (value < 0.5) {
        _skyColor = Color.lerp(Colors.orange[300], Colors.indigo[900], (value - 0.25) * 4)!;
      } else if (value < 0.75) {
        _skyColor = Color.lerp(Colors.indigo[900], Colors.purple[300], (value - 0.5) * 4)!;
      } else {
        _skyColor = Color.lerp(Colors.purple[300], Colors.blue[200], (value - 0.75) * 4)!;
      }
    });
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = 120;
      _health = 100;
      _plasticCollected = 0;
      _characterX = 100;
      _characterZ = 100;
      _characterHeight = 0;
      _plasticItems.clear();
      _waves.clear();
      _crabs.clear();
      _powerUps.clear();
      _hasSpeedBoost = false;
      _moveSpeed = 5;
      _jumpCount = 0;
      _moveVector = Offset.zero;
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

    // Game Loop (approx 60fps)
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isPlaying) _updateGameLoop();
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isPlaying) return;
      _spawnPlastic();
      if (_random.nextInt(10) < 3) _spawnWave();
      if (_random.nextInt(10) < 2) _spawnCrab();
      if (_random.nextInt(20) < 1) _spawnPowerUp();
    });
  }

  void _spawnPlastic() {
    setState(() {
      _plasticItems.add(_Plastic(
        x: _random.nextDouble() * 600 + 50,
        z: 50 + _random.nextDouble() * 200, // Random depth
        type: TrashType.values[_random.nextInt(TrashType.values.length)],
      ));
    });
  }

  void _spawnWave() {
    setState(() {
      _waves.add(_Wave(x: -50, z: 50 + _random.nextDouble() * 200));
    });
  }

  void _spawnCrab() {
    setState(() {
      _crabs.add(_Crab(
        x: _random.nextBool() ? -50 : 700,
        z: 50 + _random.nextDouble() * 200,
        direction: _random.nextBool() ? 1 : -1,
      ));
    });
  }

  void _spawnPowerUp() {
    setState(() {
      _powerUps.add(_PowerUp(
        x: _random.nextDouble() * 600 + 50,
        z: 50 + _random.nextDouble() * 200,
        type: 'speed',
      ));
    });
  }

  void _updateGameLoop() {
    setState(() {
      // Movement (X and Z)
      if (_moveVector != Offset.zero) {
        double speed = _moveSpeed * (_hasSpeedBoost ? 2 : 1);
        _characterX += _moveVector.dx * speed;
        _characterZ -= _moveVector.dy * speed; // Joystick Up is negative Y, so subtract to increase Z (move up screen)
        
        // Clamp to screen bounds
        _characterX = _characterX.clamp(20, MediaQuery.of(context).size.width - 20);
        _characterZ = _characterZ.clamp(50, 250); // Walkable depth range
      }

      // Jump Physics (Height)
      if (_isJumping || _characterHeight > 0) {
        _characterHeight += _velocityY;
        _velocityY -= 1.5; // Gravity
        if (_characterHeight <= 0) {
          _characterHeight = 0;
          _isJumping = false;
          _velocityY = 0;
          _jumpCount = 0;
        }
      }

      // Waves
      _waves.removeWhere((wave) => wave.x > 800);
      for (var wave in _waves) {
        wave.x += 5;
        // Collision: Check X, Z, and Height (must be low to get hit)
        if ((wave.x - _characterX).abs() < 40 && 
            (wave.z - _characterZ).abs() < 30 && 
            _characterHeight < 20) {
          _characterX = (_characterX - 30).clamp(20, 600);
        }
      }

      // Crabs
      _crabs.removeWhere((crab) => crab.x < -100 || crab.x > 900);
      for (var crab in _crabs) {
        crab.x += crab.direction * 3;
        // Collision
        if ((crab.x - _characterX).abs() < 30 && 
            (crab.z - _characterZ).abs() < 20 && 
            _characterHeight < 20) {
          _characterHeight += 30; // Knockback up
          _health = (_health - 10).clamp(0, 100); // Take Damage
          if (_health <= 0) {
             Future.microtask(() => _endGame(false));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🦀 أوه! السلطعون قرصك! (-10 صحة)'),
              duration: Duration(milliseconds: 500),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Auto-Collect Plastic
      _plasticItems.removeWhere((plastic) {
        bool collected = (plastic.x - _characterX).abs() < 50 && 
                         (plastic.z - _characterZ).abs() < 40 &&
                         _characterHeight < 50;
        if (collected) {
          _plasticCollected++;
          if (_plasticCollected >= _plasticGoal) {
             Future.microtask(() => _endGame(true));
          }
        }
        return collected;
      });

      // PowerUps
      _powerUps.removeWhere((p) => 
        (p.x - _characterX).abs() < 40 && 
        (p.z - _characterZ).abs() < 40 &&
        _characterHeight < 40
      );
      
      // Speed Boost Timeout
      if (_hasSpeedBoost && _random.nextInt(100) < 1) {
         _hasSpeedBoost = false;
      }
    });
  }

  void _collectPlastic(_Plastic plastic) {
    // Manual collect fallback
    if ((plastic.x - _characterX).abs() < 50 && 
        (plastic.z - _characterZ).abs() < 40 &&
        _characterHeight < 50) {
      setState(() {
        _plasticItems.remove(plastic);
        _plasticCollected++;
        if (_plasticCollected >= _plasticGoal) {
          _endGame(true);
        }
      });
    }
  }

  void _collectPowerUp(_PowerUp powerUp) {
    if ((powerUp.x - _characterX).abs() < 50 && 
        (powerUp.z - _characterZ).abs() < 50) {
      setState(() {
        _powerUps.remove(powerUp);
        if (powerUp.type == 'speed') {
          _hasSpeedBoost = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚡ سرعة خارقة!'),
              duration: Duration(milliseconds: 800),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  void _moveCharacter(double delta) {
    setState(() {
      _characterX = (_characterX + (delta > 0 ? _moveSpeed : -_moveSpeed)).clamp(50, 650);
    });
  }

  void _jump() {
    if (_jumpCount < 2) {
      setState(() {
        _isJumping = true;
        _velocityY = 20;
        _jumpCount++;
      });
    }
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
    _dayNightController.dispose();
    _rainController.dispose();
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
          // Background (Dynamic Sky)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_skyColor, Colors.blue[100]!, Colors.yellow[100]!],
              ),
            ),
          ),

          // Ocean (Background Layer)
          Positioned(
            bottom: 250, // Horizon line
            left: 0,
            right: 0,
            height: 200,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _OceanWavesPainter(_waveController.value),
                );
              },
            ),
          ),

          // Beach (Walkable Area)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.yellow[200]!, Colors.orange[100]!],
                ),
              ),
            ),
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

          // Rain Effect
          if (_isRaining)
            AnimatedBuilder(
              animation: _rainController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _RainPainter(_rainController.value),
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
                        const Text('التحكم:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('🕹️ استخدم العصا للحركة (8 اتجاهات)'),
                        const Text('⬆️ زر القفز (قفزة مزدوجة)'),
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
              fit: StackFit.expand,
              children: [
                // Plastic items (Sorted by Z for depth)
                ..._plasticItems.map((plastic) => Positioned(
                  left: plastic.x,
                  bottom: plastic.z, 
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ModernTrashIcons.icons[plastic.type] ?? '🗑️',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                )),

                // PowerUps
                ..._powerUps.map((p) => Positioned(
                  left: p.x,
                  bottom: p.z,
                  child: GestureDetector(
                    onTap: () => _collectPowerUp(p),
                    child: const Icon(Icons.flash_on, color: Colors.orange, size: 35),
                  ),
                )),

                // Waves
                ..._waves.map((wave) => Positioned(
                  left: wave.x,
                  bottom: wave.z,
                  child: Icon(Icons.water, color: Colors.blue[300], size: 40),
                )),

                // Crabs
                ..._crabs.map((crab) => Positioned(
                  left: crab.x,
                  bottom: crab.z,
                  child: const Text('🦀', style: TextStyle(fontSize: 30)),
                )),

                // Character Shadow
                Positioned(
                  left: _characterX + 10,
                  bottom: _characterZ,
                  child: Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Character
                Positioned(
                  left: _characterX,
                  bottom: _characterZ + _characterHeight, // Apply jump height
                  child: CharacterAnimator(
                    isWalking: _moveVector != Offset.zero,
                    size: 60,
                    outfit: CharacterOutfit.adventure,
                    isWoman: true,
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
              child: Column(
                children: [
                  // Health Bar
                  GameHealthBar(currentHealth: _health, maxHealth: 100),
                  const SizedBox(height: 8),
                  // Stats
                  Container(
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
                        if (_hasSpeedBoost) const Text('⚡ سرعة!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Controls (Joystick & Jump)
          if (_isPlaying)
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Joystick
                  VirtualJoystick(
                    size: 120,
                    onChange: (vector) {
                      setState(() {
                        _moveVector = vector;
                      });
                    },
                  ),
                  
                  // Jump Button
                  GestureDetector(
                    onTapDown: (_) => _jump(),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.orange,
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
    );
  }
}

class _Plastic {
  double x, z;
  TrashType type;
  _Plastic({required this.x, required this.z, required this.type});
}

class _Wave {
  double x, z;
  _Wave({required this.x, required this.z});
}

class _Crab {
  double x, z;
  int direction; // 1 or -1
  _Crab({required this.x, required this.z, required this.direction});
}

class _PowerUp {
  double x, z;
  String type;
  _PowerUp({required this.x, required this.z, required this.type});
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
    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i += 20) {
      final offset = 20 * sin((i / 50) + (animationValue * 2 * pi));
      path.lineTo(i, size.height * 0.5 + offset);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RainPainter extends CustomPainter {
  final double animationValue;
  _RainPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final random = Random(42);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * size.height * 2) % size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 5, y + 15), paint); // Slanted rain
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
