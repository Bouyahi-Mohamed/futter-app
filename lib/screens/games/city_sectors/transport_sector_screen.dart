import 'package:flutter/material.dart';

class TransportSectorScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int budget, int sustainability, int happiness)? onStatsUpdate;

  const TransportSectorScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<TransportSectorScreen> createState() => _TransportSectorScreenState();
}

class _TransportSectorScreenState extends State<TransportSectorScreen> {
  bool _isPlaying = false;
  int _publicTransportUse = 30;
  int _emissions = 80;
  int _budget = 800;
  
  final List<List<String?>> _grid = List.generate(4, (_) => List.filled(4, null));
  
  final Map<String, _TransportBuilding> _buildings = {
    'metro': _TransportBuilding(name: 'مترو', icon: Icons.directions_subway, cost: 200, usage: 25, emissions: -15, color: Colors.blue),
    'bike': _TransportBuilding(name: 'دراجات', icon: Icons.directions_bike, cost: 100, usage: 15, emissions: -20, color: Colors.green),
    'charge': _TransportBuilding(name: 'شحن', icon: Icons.ev_station, cost: 150, usage: 20, emissions: -10, color: Colors.purple),
  };

  String? _selectedBuilding;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _publicTransportUse = 30;
      _emissions = 80;
      _budget = 800;
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
      _publicTransportUse = (_publicTransportUse + building.usage).clamp(0, 100);
      _emissions += building.emissions;
      _selectedBuilding = null;
      
      if (_publicTransportUse >= 70 && _emissions <= 40) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool success) {
    setState(() => _isPlaying = false);
    widget.onStatsUpdate?.call(-180, 14, 12);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : 'انتهت المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('استخدام المواصلات: $_publicTransportUse%'),
            Text('انبعاثات النقل: $_emissions%'),
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
        title: const Text('النقل المستدام 🚇'),
        backgroundColor: Colors.blue[700],
      ),
      body: !_isPlaying
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_subway, size: 100, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text('النقل المستدام', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
                        Text('• مواصلات عامة ≥ 70%'),
                        Text('• انبعاثات ≤ 40%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ البناء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
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
                      Text('🚇 $_publicTransportUse%', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      Text('💨 $_emissions%', style: TextStyle(color: _emissions <= 40 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
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
                                  color: buildingType != null ? _buildings[buildingType]!.color : Colors.white,
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

class _TransportBuilding {
  final String name;
  final IconData icon;
  final int cost;
  final int usage;
  final int emissions;
  final Color color;

  _TransportBuilding({
    required this.name,
    required this.icon,
    required this.cost,
    required this.usage,
    required this.emissions,
    required this.color,
  });
}
