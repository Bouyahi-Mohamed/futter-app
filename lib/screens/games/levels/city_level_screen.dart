import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';
import '../../../widgets/joystick.dart';
import '../../../config/trash_icons.dart';
import '../../../widgets/game_health_bar.dart';

class CityLevelScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const CityLevelScreen({super.key, this.onComplete});

  @override
  State<CityLevelScreen> createState() => _CityLevelScreenState();
}

class _CityLevelScreenState extends State<CityLevelScreen> with TickerProviderStateMixin {
  // Game State
  int _solarPanelsInstalled = 0;
  int _streetsClean = 0;
  final int _solarGoal = 10;
  final int _streetsGoal = 5;
  int _timeLeft = 180; // 3 minutes
  int _health = 100;
  bool _isPlaying = false;
  bool _isGameEnding = false;
  Timer? _gameTimer; // Countdown timer
  Timer? _gameLoopTimer; // Physics loop timer
  
  // Physics (2.5D Platformer)
  double _characterX = 100;
  double _characterZ = 50; // Depth (0 = Front, 200 = Back)
  double _characterY = 0; // Height (0 = Ground)
  double _velocityY = 0;
  bool _isJumping = false;
  int _jumpCount = 0;
  double _moveSpeed = 10; // Increased speed
  Offset _moveVector = Offset.zero;

  // Camera
  double _cameraX = 0;
  double _worldWidth = 1200; // Expanded world

  // Environment
  final double _groundZ = 0;
  final double _buildingZ = 150; // Buildings are at the back
  final double _walkableDepth = 180;
  final double _groundOffset = 110; // Lift world above controls
  
  final List<_Building> _buildings = [];
  final List<_SolarSpot> _solarSpots = [];
  final List<_Street> _streets = [];
  final List<_Cloud> _clouds = [];
  final List<_Car> _cars = [];
  
  late AnimationController _skyController;
  Color _skyColor = Colors.lightBlue[100]!;

  @override
  void initState() {
    super.initState();
    _initializeLevel();
    
    _skyController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    _skyController.addListener(() {
      setState(() {
         // Day/Night cycle simulation
         double val = _skyController.value;
         if (val < 0.5) {
           _skyColor = Color.lerp(Colors.lightBlue[100], Colors.orange[100], val * 2)!;
         } else {
           _skyColor = Color.lerp(Colors.orange[100], Colors.indigo[100], (val - 0.5) * 2)!;
         }
      });
    });

    // Game Loop
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isPlaying) {
        try {
          _updateGameLoop();
          if (Random().nextDouble() < 0.10) _spawnCar(); // 10% chance per frame (heavy traffic)
        } catch (e) {
          debugPrint('Game Loop Error: $e');
        }
      }
    });
  }

  void _initializeLevel() {
    _buildings.clear();
    _solarSpots.clear();
    _streets.clear();
    _clouds.clear();
    _cars.clear();

    // Create buildings (More buildings for larger world)
    double currentX = 50;
    for (int i = 0; i < 6; i++) {
      int floors = 2 + Random().nextInt(3);
      _buildings.add(_Building(
        x: currentX,
        z: _buildingZ,
        floors: floors,
      ));
      
      // Add solar spots on random floors
      for (int f = 1; f <= floors; f++) {
        // Always add a spot per floor to ensure enough targets (Min 12 spots total)
        _solarSpots.add(_SolarSpot(
          x: currentX + 20 + Random().nextDouble() * 40,
          z: _buildingZ - 1, // Slightly in front of building
          y: f * 80.0,
          installed: false,
        ));
      }
      currentX += 180; // Building width + gap
    }
    _worldWidth = currentX + 100;

    // Create streets to clean
    for (int i = 0; i < 10; i++) {
      _streets.add(_Street(
        x: Random().nextDouble() * _worldWidth,
        z: Random().nextDouble() * 100, // On the street/ground
        clean: false,
        type: TrashType.values[Random().nextInt(TrashType.values.length)],
      ));
    }
    
    // Clouds
    for (int i = 0; i < 8; i++) {
      _clouds.add(_Cloud(
        x: Random().nextDouble() * _worldWidth,
        y: 300 + Random().nextDouble() * 200,
        speed: 0.5 + Random().nextDouble(),
      ));
    }

    // Initial Cars (Distributed across the map for regular traffic)
    for (int i = 0; i < 5; i++) {
      double z = Random().nextDouble() * _walkableDepth;
      bool movingRight = Random().nextBool();
      _cars.add(_Car(
        x: Random().nextDouble() * _worldWidth, // Random position on screen
        z: z,
        speed: movingRight ? 5 + Random().nextDouble() * 5 : -(5 + Random().nextDouble() * 5),
        color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
      ));
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameEnding = false;
      _timeLeft = 180;
      _health = 100;
      _solarPanelsInstalled = 0;
      _streetsClean = 0;
      _characterX = 100;
      _characterZ = 50;
      _characterY = 0;
      _velocityY = 0;
      
      // Initialize camera to center on character
      double screenWidth = MediaQuery.of(context).size.width;
      _cameraX = (_characterX - screenWidth / 2).clamp(0, _worldWidth - screenWidth);
      if (_cameraX < 0) _cameraX = 0;
      
      for (var spot in _solarSpots) spot.installed = false;
      for (var spot in _solarSpots) spot.installed = false;
      for (var street in _streets) street.clean = false;
      _cars.clear();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame(false);
        }
      });
    });
  }

  void _updateGameLoop() {
    setState(() {
      // 1. Movement (X and Z)
      if (_moveVector != Offset.zero) {
        _characterX += _moveVector.dx * _moveSpeed;
        _characterZ -= _moveVector.dy * _moveSpeed; // Up joystick = Increase Z (move back)
        
        // Clamp X
        _characterX = _characterX.clamp(0, _worldWidth);
        
        // Clamp Z (Walkable area)
        _characterZ = _characterZ.clamp(0, _walkableDepth);
      }

      // 2. Gravity & Jumping
      _velocityY -= 0.8; // Gravity
      _characterY += _velocityY;

      // 3. Collision Detection (Ground & Buildings)
      bool onGround = false;
      
      // Check Buildings
      for (var building in _buildings) {
        // Check if within building horizontal bounds (X and Z)
        bool inBuildingX = _characterX >= building.x && _characterX <= building.x + building.width;
        bool inBuildingZ = (_characterZ - building.z).abs() < 30; // Close to building plane
        
        if (inBuildingX && inBuildingZ) {
          // Check floors
          for (int f = 1; f <= building.floors; f++) {
            double floorHeight = f * building.floorHeight;
            // Land on floor
            if (_characterY <= floorHeight + 5 && _characterY >= floorHeight - 10 && _velocityY <= 0) {
              _characterY = floorHeight;
              _velocityY = 0;
              _isJumping = false;
              _jumpCount = 0;
              onGround = true;
              break;
            }
          }
        }
      }

      // Check Ground
      if (!onGround && _characterY <= 0) {
        _characterY = 0;
        _velocityY = 0;
        _isJumping = false;
        _jumpCount = 0;
        onGround = true;
      }

      // 4. Interactions
      _checkInteractions();
      
      // 5. Clouds
      for (var cloud in _clouds) {
        cloud.x -= cloud.speed;
        if (cloud.x < -100) cloud.x = _worldWidth + 100;
        if (cloud.x < -100) cloud.x = _worldWidth + 100;
      }

      // 6. Cars
      for (int i = _cars.length - 1; i >= 0; i--) {
        final car = _cars[i];
        car.x += car.speed;
        
        // Remove if off screen
        if (car.x > _worldWidth + 100 || car.x < -100) {
          _cars.removeAt(i);
          continue;
        }

        // Collision with Player
        if ((_characterX - car.x).abs() < 50 &&
            (_characterZ - car.z).abs() < 30 &&
            _characterY < 20) { // Hit if on ground
          _health -= 1; // Damage
          if (_health <= 0) _endGame(false);
          _showFeedback('🚗 احترس!', Colors.red);
          // Knockback
          _characterY += 20;
          _velocityY = 10;
        }
      }
      
      // 6. Camera Follow
      // Center the camera on the character, but clamp to world bounds
      double screenWidth = MediaQuery.of(context).size.width;
      double targetCamX = _characterX - screenWidth / 2;
      _cameraX = targetCamX.clamp(0, _worldWidth - screenWidth);
      if (_cameraX < 0) _cameraX = 0; // Handle small screens
    });
  }

  void _checkInteractions() {
    // Solar Panels
    for (var spot in _solarSpots) {
      if (!spot.installed &&
          (_characterX - spot.x).abs() < 40 &&
          (_characterY - spot.y).abs() < 20 &&
          (_characterZ - spot.z).abs() < 40) {
        spot.installed = true;
        _solarPanelsInstalled++;
        _showFeedback('☀️ تم التركيب!', Colors.orange);
        _checkMissionComplete();
      }
    }

    // Streets
    for (var street in _streets) {
      if (!street.clean &&
          (_characterX - street.x).abs() < 40 &&
          (_characterY - 0).abs() < 10 && // Must be on ground
          (_characterZ - street.z).abs() < 40) {
        street.clean = true;
        _streetsClean++;
        _showFeedback('🧹 تم التنظيف!', Colors.green);
        _checkMissionComplete();
      }
    }
  }

  void _checkMissionComplete() {
    if (!_isGameEnding && _solarPanelsInstalled >= _solarGoal && _streetsClean >= _streetsGoal) {
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
      ),
    );
  }

  void _jump() {
    if (_jumpCount < 2) {
      setState(() {
        _velocityY = 18; // Higher jump
        _isJumping = true;
        _jumpCount++;
      });
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

  void _spawnCar() {
    // Spawn on a random Z depth that corresponds to a "street" or walkable area
    double z = Random().nextDouble() * _walkableDepth;
    bool movingRight = Random().nextBool();
    
    _cars.add(_Car(
      x: movingRight ? -100 : _worldWidth + 100,
      z: z,
      speed: movingRight ? 5 + Random().nextDouble() * 5 : -(5 + Random().nextDouble() * 5),
      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    ));
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _gameLoopTimer?.cancel();
    _skyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure visuals cover the screen even if the world is smaller
    double screenWidth = MediaQuery.of(context).size.width;
    double visualWidth = max(_worldWidth, screenWidth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المدينة الإيكولوجية 🏙️'),
        backgroundColor: Colors.blue[800],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed Background (Sky)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_skyColor, Colors.white],
              ),
            ),
          ),
          
          // Clouds (Parallax)
          ..._clouds.map((c) => Positioned(
            left: c.x - _cameraX, // Apply camera offset
            top: c.y,
            child: Icon(Icons.cloud, color: Colors.white.withOpacity(0.8), size: 60),
          )),

          // Ground Visual
          Positioned(
            bottom: 0,
            left: -_cameraX, // Apply camera offset
            width: visualWidth,
            height: _walkableDepth + _groundOffset + 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
              ),
            ),
          ),

          // City Skyline (Far Background)
          Positioned(
            bottom: 200 + _groundOffset,
            left: -_cameraX * 0.5, // Parallax effect
            width: visualWidth, 
            child: Opacity(
              opacity: 0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate((visualWidth / 50).ceil() + 5, (index) => Container(
                    width: 50 + Random().nextDouble() * 50,
                    height: 100 + Random().nextDouble() * 200,
                    color: Colors.grey[400],
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                  )),
                ),
              ),
            ),
          ),

          // Game Objects
          if (_isPlaying) ...[
            // Buildings
            ..._buildings.map((b) => Positioned(
              left: b.x - _cameraX,
              bottom: b.z + _groundOffset,
              child: _buildBuildingWidget(b),
            )),

            // Solar Spots
            ..._solarSpots.map((s) => Positioned(
              left: s.x - _cameraX,
              bottom: s.z + s.y + _groundOffset,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.installed ? Colors.orange.withOpacity(0.8) : Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    if (!s.installed)
                      BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Icon(
                  s.installed ? Icons.check : Icons.solar_power,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            )),

            // Streets (Trash)
            ..._streets.where((s) => !s.clean).map((s) => Positioned(
              left: s.x - _cameraX,
              bottom: s.z + _groundOffset,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _getTrashColor(s.type).withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _getTrashColor(s.type).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    ModernTrashIcons.icons[s.type] ?? '🗑️',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            )),

            // Cars
            ..._cars.map((car) => Positioned(
              left: car.x - _cameraX,
              bottom: car.z + _groundOffset,
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: car.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 5)),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Car Body
                    Positioned(
                      bottom: 5, left: 0, right: 0, height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: car.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    // Roof
                    Positioned(
                      bottom: 20, left: 15, right: 15, height: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: car.color.withOpacity(0.8),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ),
                    ),
                    // Wheels
                    Positioned(bottom: 0, left: 10, child: CircleAvatar(radius: 8, backgroundColor: Colors.black)),
                    Positioned(bottom: 0, right: 10, child: CircleAvatar(radius: 8, backgroundColor: Colors.black)),
                  ],
                ),
              ),
            )),

            // Character
            Positioned(
              left: _characterX - _cameraX,
              bottom: _characterZ + _characterY + _groundOffset,
              child: Column(
                children: [
                  CharacterAnimator(
                    isWalking: _moveVector != Offset.zero,
                    size: 60,
                    outfit: CharacterOutfit.city,
                    isWoman: true,
                  ),
                  Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),

            // HUD
            // Stats
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: IgnorePointer(
                child: Column(
                  children: [
                    GameHealthBar(currentHealth: _health, maxHealth: 100),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('$_timeLeft', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 20),
                          const Icon(Icons.solar_power, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('$_solarPanelsInstalled/$_solarGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 20),
                          const Icon(Icons.cleaning_services, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('$_streetsClean/$_streetsGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // DEBUG OVERLAY (Removed)
            // Controls
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
            Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onTapDown: (_) => _jump(),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.arrow_upward, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],

          if (!_isPlaying)
            _buildStartScreen(),
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
              '🏙️ المدينة المستدامة',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildMissionItem(Icons.solar_power, 'ركب $_solarGoal ألواح شمسية', Colors.orange),
            _buildMissionItem(Icons.cleaning_services, 'نظف $_streetsGoal شوارع', Colors.green),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('ابدأ المهمة'),
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

  Widget _buildBuildingWidget(_Building building) {
    // Removed fixed height to avoid RenderFlex overflow
    return Container(
      width: building.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey[600]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(building.floors, (i) {
          return Container(
            height: building.floorHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[400]!)),
              color: i % 2 == 0 ? Colors.grey[350] : Colors.grey[300],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 20, height: 40, color: Colors.blue[100]),
                Container(width: 20, height: 40, color: Colors.blue[100]),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _getTrashColor(TrashType type) {
    switch (type) {
      case TrashType.plastic:
        return Colors.blue;
      case TrashType.glass:
        return Colors.cyan;
      case TrashType.paper:
        return Colors.brown;
      case TrashType.metal:
        return Colors.grey;
      case TrashType.organic:
        return Colors.green;
      case TrashType.electronic:
        return Colors.purple;
    }
  }
}

class _Building {
  final double x, z;
  final int floors;
  final double width = 100;
  final double floorHeight = 80;
  _Building({required this.x, required this.z, required this.floors});
}

class _SolarSpot {
  final double x, z, y;
  bool installed;
  _SolarSpot({required this.x, required this.z, required this.y, required this.installed});
}

class _Street {
  final double x, z;
  final TrashType type;
  bool clean;
  _Street({required this.x, required this.z, required this.clean, required this.type});
}

class _Cloud {
  double x, y, speed;
  _Cloud({required this.x, required this.y, required this.speed});
}

class _Car {
  double x, z, speed;
  Color color;
  _Car({required this.x, required this.z, required this.speed, required this.color});
}

class _RenderItem {
  final double z;
  final double y;
  final Widget widget;
  _RenderItem({required this.z, required this.y, required this.widget});
}


