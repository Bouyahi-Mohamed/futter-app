import 'dart:async';
import 'package:flutter/material.dart';

class WasteSectorScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int budget, int sustainability, int happiness)? onStatsUpdate;

  const WasteSectorScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<WasteSectorScreen> createState() => _WasteSectorScreenState();
}

class _WasteSectorScreenState extends State<WasteSectorScreen> {
  bool _isPlaying = false;
  int _recyclingRate = 20;
  int _wasteAmount = 100;
  int _sorted = 0;
  final int _sortGoal = 15;
  Timer? _wasteTimer;
  
  final List<_WasteItem> _wasteItems = [];

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _sorted = 0;
      _wasteItems.clear();
    });

    _wasteTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _spawnWaste();
    });
  }

  void _spawnWaste() {
    final types = ['plastic', 'paper', 'glass', 'organic'];
    setState(() {
      _wasteItems.add(_WasteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: types[_wasteItems.length % types.length],
        x: 50 + (_wasteItems.length % 3) * 200.0,
        y: 100,
      ));
    });
  }

  void _sortWaste(_WasteItem item) {
    setState(() {
      _wasteItems.remove(item);
      _sorted++;
      _recyclingRate = ((_sorted / _sortGoal) * 80 + 20).round().clamp(0, 100);
      _wasteAmount = (100 - _recyclingRate).clamp(0, 100);
      
      if (_sorted >= _sortGoal) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool success) {
    _wasteTimer?.cancel();
    setState(() => _isPlaying = false);
    widget.onStatsUpdate?.call(-150, 12, 8);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : 'انتهت المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نسبة التدوير: $_recyclingRate%'),
            Text('نفايات مفروزة: $_sorted / $_sortGoal'),
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
  void dispose() {
    _wasteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة النفايات 🗑️'),
        backgroundColor: Colors.green[700],
      ),
      body: !_isPlaying
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.recycling, size: 100, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text('إدارة النفايات', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
                        const Text('الهدف:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('• فرز $_sortGoal قطعة نفايات'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ الفرز'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Container(color: Colors.grey[200]),
                // Waste items
                ..._wasteItems.map((item) => Positioned(
                  left: item.x,
                  top: item.y,
                  child: GestureDetector(
                    onTap: () => _sortWaste(item),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getWasteColor(item.type),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
                        ],
                      ),
                      child: Icon(_getWasteIcon(item.type), color: Colors.white, size: 40),
                    ),
                  ),
                )),
                // Stats
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
                        Text('♻️ $_recyclingRate%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Text('✅ $_sorted/$_sortGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Instructions
                const Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Text(
                    'اضغط على النفايات لفرزها!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  Color _getWasteColor(String type) {
    switch (type) {
      case 'plastic': return Colors.blue[700]!;
      case 'paper': return Colors.brown[700]!;
      case 'glass': return Colors.green[700]!;
      case 'organic': return Colors.orange[700]!;
      default: return Colors.grey;
    }
  }

  IconData _getWasteIcon(String type) {
    switch (type) {
      case 'plastic': return Icons.local_drink;
      case 'paper': return Icons.description;
      case 'glass': return Icons.wine_bar;
      case 'organic': return Icons.eco;
      default: return Icons.delete;
    }
  }
}

class _WasteItem {
  final String id;
  final String type;
  final double x;
  final double y;

  _WasteItem({required this.id, required this.type, required this.x, required this.y});
}
