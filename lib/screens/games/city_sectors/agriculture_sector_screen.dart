import 'package:flutter/material.dart';

class AgricultureSectorScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int budget, int sustainability, int happiness)? onStatsUpdate;

  const AgricultureSectorScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<AgricultureSectorScreen> createState() => _AgricultureSectorScreenState();
}

class _AgricultureSectorScreenState extends State<AgricultureSectorScreen> {
  bool _isPlaying = false;
  int _localProduction = 20;
  int _greenSpace = 30;
  int _budget = 700;
  
  final List<List<String?>> _grid = List.generate(4, (_) => List.filled(4, null));
  
  final Map<String, _FarmBuilding> _buildings = {
    'vertical': _FarmBuilding(name: 'عمودي', icon: Icons.apartment, cost: 180, production: 25, green: 10, color: Colors.green),
    'roof': _FarmBuilding(name: 'أسطح', icon: Icons.roofing, cost: 120, production: 15, green: 20, color: Colors.lightGreen),
    'garden': _FarmBuilding(name: 'حديقة', icon: Icons.park, cost: 100, production: 10, green: 30, color: Colors.teal),
  };

  String? _selectedBuilding;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _localProduction = 20;
      _greenSpace = 30;
      _budget = 700;
      for (var row in _grid) {
        row.fillRange(0, row.length, null);
      }
    });
  }

  void _selectBuilding(String type) {
    setState(() => _selectedBuilding = type);
  }

  void _placeBuilding(int row, int col) {
    if (_selectedBuilding == null || _grid[row][col] != null) return;
    
    final building = _buildings[_selectedBuilding]!;
    if (_budget < building.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ميزانية غير كافية!')),
      );
      return;
    }

    setState(() {
      _grid[row][col] = _selectedBuilding;
      _budget -= building.cost;
      _localProduction = (_localProduction + building.production).clamp(0, 100);
      _greenSpace = (_greenSpace + building.green).clamp(0, 100);
      _selectedBuilding = null;
      
      if (_localProduction >= 60 && _greenSpace >= 70) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool success) {
    setState(() => _isPlaying = false);
    widget.onStatsUpdate?.call(-170, 18, 15);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : 'انتهت المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('إنتاج محلي: $_localProduction%'),
            Text('مساحات خضراء: $_greenSpace%'),
            if (success) const Text('\nمدينة خضراء مستدامة!'),
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
        title: const Text('الزراعة الحضرية 🌿'),
        backgroundColor: Colors.green[700],
      ),
      body: !_isPlaying
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture, size: 100, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text('الزراعة الحضرية', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
                        Text('الهدف:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('• إنتاج محلي ≥ 60%'),
                        Text('• مساحات خضراء ≥ 70%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ الزراعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('💰 \$$_budget', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('🌾 $_localProduction%', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      Text('🌳 $_greenSpace%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: 16,
                          itemBuilder: (context, index) {
                            final row = index ~/ 4;
                            final col = index % 4;
                            final buildingType = _grid[row][col];
                            
                            return GestureDetector(
                              onTap: () => _placeBuilding(row, col),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: buildingType != null ? _buildings[buildingType]!.color : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[300]!, width: 2),
                                ),
                                child: buildingType != null
                                    ? Icon(_buildings[buildingType]!.icon, color: Colors.white, size: 32)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildings.entries.map((entry) {
                      final isSelected = _selectedBuilding == entry.key;
                      return GestureDetector(
                        onTap: () => _selectBuilding(entry.key),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? entry.value.color : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.yellow : Colors.grey, width: 3),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(entry.value.icon, color: isSelected ? Colors.white : entry.value.color, size: 32),
                              const SizedBox(height: 4),
                              Text(entry.value.name, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                              Text('\$${entry.value.cost}', style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FarmBuilding {
  final String name;
  final IconData icon;
  final int cost;
  final int production;
  final int green;
  final Color color;

  _FarmBuilding({
    required this.name,
    required this.icon,
    required this.cost,
    required this.production,
    required this.green,
    required this.color,
  });
}
