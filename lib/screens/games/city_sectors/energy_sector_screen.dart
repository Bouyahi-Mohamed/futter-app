import 'package:flutter/material.dart';

class EnergySectorScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int budget, int sustainability, int happiness)? onStatsUpdate;

  const EnergySectorScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<EnergySectorScreen> createState() => _EnergySectorScreenState();
}

class _EnergySectorScreenState extends State<EnergySectorScreen> {
  bool _isPlaying = false;
  int _energyProduction = 0;
  int _emissions = 100;
  int _budget = 1000;
  
  final List<List<String?>> _grid = List.generate(4, (_) => List.filled(4, null));
  
  final Map<String, _Building> _buildings = {
    'solar': _Building(name: 'شمسي', icon: Icons.wb_sunny, cost: 150, energy: 30, emissions: -10, color: Colors.orange),
    'wind': _Building(name: 'رياح', icon: Icons.air, cost: 200, energy: 40, emissions: -15, color: Colors.blue),
    'waste': _Building(name: 'نفايات', icon: Icons.delete, cost: 100, energy: 20, emissions: -5, color: Colors.green),
  };

  String? _selectedBuilding;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _energyProduction = 0;
      _emissions = 100;
      _budget = 1000;
      for (var row in _grid) {
        row.fillRange(0, row.length, null);
      }
    });
  }

  void _selectBuilding(String type) {
    setState(() {
      _selectedBuilding = type;
    });
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
      _energyProduction += building.energy;
      _emissions += building.emissions;
      _selectedBuilding = null;
      
      if (_energyProduction >= 120 && _emissions <= 50) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool success) {
    setState(() => _isPlaying = false);
    widget.onStatsUpdate?.call(-200, 15, 10);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : 'انتهت المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('إنتاج الطاقة: $_energyProduction'),
            Text('الانبعاثات: $_emissions%'),
            if (success) const Text('\nشبكة طاقة مستدامة!'),
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
        title: const Text('منطقة الطاقة ⚡'),
        backgroundColor: Colors.amber[700],
      ),
      body: !_isPlaying
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, size: 100, color: Colors.amber),
                  const SizedBox(height: 20),
                  const Text('منطقة الطاقة', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
                        Text('• إنتاج طاقة ≥ 120'),
                        Text('• انبعاثات ≤ 50%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ البناء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('💰 \$$_budget', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('⚡ $_energyProduction', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      Text('💨 $_emissions%', style: TextStyle(color: _emissions <= 50 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Grid
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
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
                                  color: buildingType != null
                                      ? _buildings[buildingType]!.color
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[400]!, width: 2),
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
                // Building selector
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
                            border: Border.all(
                              color: isSelected ? Colors.yellow : Colors.grey,
                              width: 3,
                            ),
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

class _Building {
  final String name;
  final IconData icon;
  final int cost;
  final int energy;
  final int emissions;
  final Color color;

  _Building({
    required this.name,
    required this.icon,
    required this.cost,
    required this.energy,
    required this.emissions,
    required this.color,
  });
}
