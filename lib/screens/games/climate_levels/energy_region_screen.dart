import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class EnergyRegionScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int co2, int economy, int support)? onStatsUpdate;

  const EnergyRegionScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<EnergyRegionScreen> createState() => _EnergyRegionScreenState();
}

class _EnergyRegionScreenState extends State<EnergyRegionScreen> {
  bool _isPlaying = false;
  int _renewablePercentage = 20;
  int _gridEfficiency = 40;
  int _budget = 1000;
  
  final List<_PowerPlant> _plants = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializePlants();
  }

  void _initializePlants() {
    _plants.addAll([
      _PowerPlant(id: 1, type: 'coal', x: 100, y: 200, active: true),
      _PowerPlant(id: 2, type: 'coal', x: 300, y: 250, active: true),
      _PowerPlant(id: 3, type: 'gas', x: 500, y: 200, active: true),
      _PowerPlant(id: 4, type: 'coal', x: 200, y: 350, active: true),
    ]);
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _renewablePercentage = 20;
      _gridEfficiency = 40;
      _budget = 1000;
      for (var plant in _plants) {
        plant.type = plant.id <= 3 ? 'coal' : 'gas';
        plant.active = true;
      }
    });
  }

  void _upgradePlant(_PowerPlant plant) {
    int cost = 0;
    String newType = '';
    
    if (plant.type == 'coal') {
      cost = 200;
      newType = 'gas';
    } else if (plant.type == 'gas') {
      cost = 300;
      newType = 'solar';
    } else if (plant.type == 'solar') {
      cost = 400;
      newType = 'wind';
    }

    if (cost > 0 && _budget >= cost) {
      setState(() {
        _budget -= cost;
        plant.type = newType;
        _calculateStats();
      });
    } else if (cost > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ميزانية غير كافية!')),
      );
    }
  }

  void _calculateStats() {
    int renewable = 0;
    int total = _plants.where((p) => p.active).length;
    
    for (var plant in _plants.where((p) => p.active)) {
      if (plant.type == 'solar' || plant.type == 'wind') {
        renewable++;
      }
    }
    
    _renewablePercentage = total > 0 ? ((renewable / total) * 100).round() : 0;
    _gridEfficiency = 40 + (_renewablePercentage ~/ 2);
    
    if (_renewablePercentage >= 75) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    setState(() => _isPlaying = false);
    
    // Update global stats
    widget.onStatsUpdate?.call(-15, -8, 12);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : '⚠️ انتهت المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الطاقة المتجددة: $_renewablePercentage%'),
            Text('كفاءة الشبكة: $_gridEfficiency%'),
            if (success) const Text('\nتم تحديث شبكة الطاقة بنجاح!'),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شبكة الطاقة العالمية ⚡'),
        backgroundColor: Colors.amber[700],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.yellow[100]!, Colors.amber[100]!, Colors.orange[100]!],
              ),
            ),
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, size: 100, color: Colors.amber),
                  const SizedBox(height: 20),
                  const Text(
                    'شبكة الطاقة العالمية',
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
                        Text('• اعتماد على الوقود الأحفوري'),
                        Text('• بنية تحتية قديمة'),
                        SizedBox(height: 10),
                        Text('الهدف:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('• طاقة متجددة ≥ 75%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
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
                // Power plants
                ..._plants.map((plant) => Positioned(
                  left: plant.x,
                  top: plant.y,
                  child: GestureDetector(
                    onTap: () => _upgradePlant(plant),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getPlantColor(plant.type),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getPlantIcon(plant.type),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPlantName(plant.type),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                      'اضغط على المحطات للترقية:\nفحم → غاز → شمسي → رياح',
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
                    Text('💰 \$$_budget', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('♻️ متجددة: $_renewablePercentage%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('⚡ كفاءة: $_gridEfficiency%', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPlantColor(String type) {
    switch (type) {
      case 'coal': return Colors.grey[800]!;
      case 'gas': return Colors.blue[700]!;
      case 'solar': return Colors.orange[600]!;
      case 'wind': return Colors.green[600]!;
      default: return Colors.grey;
    }
  }

  IconData _getPlantIcon(String type) {
    switch (type) {
      case 'coal': return Icons.factory;
      case 'gas': return Icons.local_fire_department;
      case 'solar': return Icons.wb_sunny;
      case 'wind': return Icons.air;
      default: return Icons.power;
    }
  }

  String _getPlantName(String type) {
    switch (type) {
      case 'coal': return 'فحم';
      case 'gas': return 'غاز';
      case 'solar': return 'شمسي';
      case 'wind': return 'رياح';
      default: return '';
    }
  }
}

class _PowerPlant {
  final int id;
  String type;
  final double x;
  final double y;
  bool active;

  _PowerPlant({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.active,
  });
}
