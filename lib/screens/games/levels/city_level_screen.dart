import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';

class CityLevelScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const CityLevelScreen({super.key, this.onComplete});

  @override
  State<CityLevelScreen> createState() => _CityLevelScreenState();
}

class _CityLevelScreenState extends State<CityLevelScreen> {
  int _solarPanelsInstalled = 0;
  int _streetsClean = 0;
  final int _solarGoal = 10;
  final int _streetsGoal = 5;
  int _timeLeft = 150; // 2.5 minutes
  bool _isPlaying = false;
  Timer? _gameTimer;

  double _characterX = 100;
  double _characterY = 400; // Ground level
  int _currentFloor = 0; // 0 = ground, 1-5 = buildings

  final List<_Building> _buildings = [];
  final List<_SolarSpot> _solarSpots = [];
  final List<_Street> _streets = [];

  @override
  void initState() {
    super.initState();
    _initializeLevel();
  }

  void _initializeLevel() {
    // Create buildings
    for (int i = 0; i < 5; i++) {
      _buildings.add(_Building(
        x: 100.0 + i * 120,
        floors: 3 + Random().nextInt(3),
      ));
    }

    // Create solar panel spots on rooftops
    for (var building in _buildings) {
      for (int i = 0; i < 2; i++) {
        _solarSpots.add(_SolarSpot(
          x: building.x + 20 + i * 40,
          y: 100.0,
          installed: false,
        ));
      }
    }

    // Create streets to clean
    for (int i = 0; i < 5; i++) {
      _streets.add(_Street(
        x: 50.0 + i * 130,
        y: 450,
        clean: false,
      ));
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = 150;
      _solarPanelsInstalled = 0;
      _streetsClean = 0;
      _characterX = 100;
      _characterY = 400;

      for (var spot in _solarSpots) {
        spot.installed = false;
      }
      for (var street in _streets) {
        street.clean = false;
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
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
        _characterY = (_characterY - 80).clamp(100, 450);
      } else if (direction == 'down') {
        _characterY = (_characterY + 80).clamp(100, 450);
      }

      _checkInteractions();
    });
  }

  void _checkInteractions() {
    // Check solar panel installation
    for (var spot in _solarSpots) {
      if (!spot.installed &&
          (_characterX - spot.x).abs() < 40 &&
          (_characterY - spot.y).abs() < 40) {
        setState(() {
          spot.installed = true;
          _solarPanelsInstalled++;
        });
      }
    }

    // Check street cleaning
    for (var street in _streets) {
      if (!street.clean &&
          (_characterX - street.x).abs() < 50 &&
          (_characterY - street.y).abs() < 40) {
        setState(() {
          street.clean = true;
          _streetsClean++;
        });
      }
    }

    if (_solarPanelsInstalled >= _solarGoal && _streetsClean >= _streetsGoal) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    _gameTimer?.cancel();
    setState(() => _isPlaying = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 مهمة مكتملة!' : '⏱️ انتهى الوقت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ألواح شمسية: $_solarPanelsInstalled / $_solarGoal'),
            Text('شوارع نظيفة: $_streetsClean / $_streetsGoal'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المدينة الإيكولوجية 🏙️'),
        backgroundColor: Colors.grey[700],
      ),
      body: Stack(
        children: [
          // Background - City skyline
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[200]!],
              ),
            ),
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'المدينة الإيكولوجية',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                        Text('☀️ تركيب $_solarGoal ألواح شمسية'),
                        Text('🧹 تنظيف $_streetsGoal شوارع'),
                        const SizedBox(height: 10),
                        const Text('التحدي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('التسلق على المباني'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
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
                // Buildings
                ..._buildings.map((building) => Positioned(
                  left: building.x,
                  bottom: 50,
                  child: Container(
                    width: 80,
                    height: building.floors * 80.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      children: List.generate(
                        building.floors,
                        (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            color: Colors.yellow[200],
                          ),
                        ),
                      ),
                    ),
                  ),
                )),

                // Solar spots
                ..._solarSpots.map((spot) => Positioned(
                  left: spot.x,
                  top: spot.y,
                  child: Icon(
                    spot.installed ? Icons.solar_power : Icons.circle,
                    color: spot.installed ? Colors.orange : Colors.grey,
                    size: spot.installed ? 35 : 20,
                  ),
                )),

                // Streets
                ..._streets.map((street) => Positioned(
                  left: street.x,
                  bottom: 20,
                  child: Container(
                    width: 100,
                    height: 20,
                    color: street.clean ? Colors.grey[400] : Colors.brown[400],
                    child: street.clean
                        ? const Icon(Icons.check, color: Colors.green, size: 16)
                        : const Icon(Icons.delete, color: Colors.red, size: 16),
                  ),
                )),

                // Character
                Positioned(
                  left: _characterX,
                  top: _characterY,
                  child: const CharacterAnimator(
                    isWalking: true,
                    size: 50,
                    outfit: CharacterOutfit.city,
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
                    Text('☀️ $_solarPanelsInstalled/$_solarGoal', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    Text('🧹 $_streetsClean/$_streetsGoal', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
      ),
      child: Icon(icon, size: 24),
    );
  }
}

class _Building {
  final double x;
  final int floors;
  _Building({required this.x, required this.floors});
}

class _SolarSpot {
  final double x, y;
  bool installed;
  _SolarSpot({required this.x, required this.y, required this.installed});
}

class _Street {
  final double x, y;
  bool clean;
  _Street({required this.x, required this.y, required this.clean});
}
