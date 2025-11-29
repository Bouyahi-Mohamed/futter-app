import 'dart:async';
import 'package:flutter/material.dart';

class HotspotRegionScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int co2, int economy, int support)? onStatsUpdate;

  const HotspotRegionScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<HotspotRegionScreen> createState() => _HotspotRegionScreenState();
}

class _HotspotRegionScreenState extends State<HotspotRegionScreen> {
  bool _isPlaying = false;
  int _protectedArea = 20;
  int _biodiversity = 40;
  int _timeLeft = 90;
  Timer? _gameTimer;
  
  final List<_Ecosystem> _ecosystems = [];

  @override
  void initState() {
    super.initState();
    _initializeEcosystems();
  }

  void _initializeEcosystems() {
    _ecosystems.addAll([
      _Ecosystem(
        id: 1,
        name: 'الغابات الاستوائية',
        icon: Icons.forest,
        color: Colors.green,
        health: 30,
        x: 150,
        y: 200,
      ),
      _Ecosystem(
        id: 2,
        name: 'المناطق القطبية',
        icon: Icons.ac_unit,
        color: Colors.blue,
        health: 25,
        x: 450,
        y: 150,
      ),
      _Ecosystem(
        id: 3,
        name: 'الشعاب المرجانية',
        icon: Icons.water,
        color: Colors.cyan,
        health: 20,
        x: 300,
        y: 350,
      ),
    ]);
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _protectedArea = 20;
      _biodiversity = 40;
      _timeLeft = 90;
      for (var eco in _ecosystems) {
        eco.health = eco.id == 1 ? 30 : (eco.id == 2 ? 25 : 20);
        eco.protected = false;
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          // Degrade unprotected ecosystems
          for (var eco in _ecosystems.where((e) => !e.protected)) {
            eco.health = (eco.health - 0.5).clamp(0, 100);
          }
          _calculateStats();
        } else {
          _endGame(false);
        }
      });
    });
  }

  void _protectEcosystem(_Ecosystem ecosystem) {
    if (!ecosystem.protected) {
      setState(() {
        ecosystem.protected = true;
        ecosystem.health = (ecosystem.health + 30).clamp(0, 100);
        _calculateStats();
      });
    }
  }

  void _calculateStats() {
    int protected = _ecosystems.where((e) => e.protected).length;
    _protectedArea = ((protected / _ecosystems.length) * 100).round();
    
    double avgHealth = _ecosystems.map((e) => e.health).reduce((a, b) => a + b) / _ecosystems.length;
    _biodiversity = avgHealth.round();
    
    if (_protectedArea >= 100 && _biodiversity >= 60) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    _gameTimer?.cancel();
    setState(() => _isPlaying = false);
    
    widget.onStatsUpdate?.call(-8, -3, 8);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : '⏱️ انتهى الوقت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('مساحة المحميات: $_protectedArea%'),
            Text('التنوع الحيوي: $_biodiversity%'),
            if (success) const Text('\nتم حماية النقاط الساخنة!'),
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
        title: const Text('النقاط الساخنة البيئية 🔥'),
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
                colors: [Colors.green[100]!, Colors.teal[100]!, Colors.blue[100]!],
              ),
            ),
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.nature, size: 100, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    'النقاط الساخنة البيئية',
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
                    child: const Column(
                      children: [
                        Text('التحديات:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('• انحسار الغابات'),
                        Text('• ذوبان الجليد'),
                        Text('• تبيض المرجان'),
                        SizedBox(height: 10),
                        Text('الأهداف:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('• حماية جميع النظم البيئية'),
                        Text('• تنوع حيوي ≥ 60%'),
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
                    ),
                  ),
                ],
              ),
            )
          else
            Stack(
              children: [
                // Ecosystems
                ..._ecosystems.map((eco) => Positioned(
                  left: eco.x,
                  top: eco.y,
                  child: GestureDetector(
                    onTap: () => _protectEcosystem(eco),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: eco.protected ? Colors.green[600] : eco.color[700],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: eco.protected ? Colors.yellow : Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            eco.protected ? Icons.shield : eco.icon,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                eco.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                'صحة: ${eco.health.round()}%',
                                style: TextStyle(
                                  color: eco.health > 50 ? Colors.green : Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

                // Instructions
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'اضغط على النظم البيئية لحمايتها!\nالنظم غير المحمية تتدهور بمرور الوقت',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

          // Stats HUD
          if (_isPlaying)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('⏱️ $_timeLeft ث', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('🛡️ محميات: $_protectedArea%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('🌿 تنوع: $_biodiversity%', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Ecosystem {
  final int id;
  final String name;
  final IconData icon;
  final MaterialColor color;
  double health;
  bool protected;
  final double x;
  final double y;

  _Ecosystem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.health,
    this.protected = false,
    required this.x,
    required this.y,
  });
}
