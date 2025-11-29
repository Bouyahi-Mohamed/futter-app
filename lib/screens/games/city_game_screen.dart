import 'package:flutter/material.dart';

class CityGameScreen extends StatefulWidget {
  const CityGameScreen({super.key});

  @override
  State<CityGameScreen> createState() => _CityGameScreenState();
}

class _CityGameScreenState extends State<CityGameScreen> {
  int _budget = 1000;
  int _sustainabilityScore = 20;
  
  // Buildings state (0: Dirty, 1: Improved, 2: Green)
  int _powerPlantLevel = 0;
  int _transportLevel = 0;
  int _wasteLevel = 0;

  void _upgradeBuilding(String type) {
    setState(() {
      int cost = 0;
      int scoreGain = 0;

      if (type == 'power') {
        if (_powerPlantLevel < 2) {
          cost = (_powerPlantLevel + 1) * 300;
          scoreGain = 25;
          if (_budget >= cost) {
            _budget -= cost;
            _powerPlantLevel++;
            _sustainabilityScore += scoreGain;
          }
        }
      } else if (type == 'transport') {
        if (_transportLevel < 2) {
          cost = (_transportLevel + 1) * 250;
          scoreGain = 20;
          if (_budget >= cost) {
            _budget -= cost;
            _transportLevel++;
            _sustainabilityScore += scoreGain;
          }
        }
      } else if (type == 'waste') {
        if (_wasteLevel < 2) {
          cost = (_wasteLevel + 1) * 200;
          scoreGain = 15;
          if (_budget >= cost) {
            _budget -= cost;
            _wasteLevel++;
            _sustainabilityScore += scoreGain;
          }
        }
      }
    });

    if (_sustainabilityScore >= 100) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('مدينة مستدامة!'),
        content: const Text('تهانينا! لقد حولت المدينة إلى مدينة خضراء بالكامل.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('تحدي المدينة المستدامة')),
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('الميزانية', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$$_budget', style: const TextStyle(fontSize: 20, color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    const Text('الاستدامة', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_sustainabilityScore%', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          
          // City View (Visual Representation)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.blue[50],
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Ground
                  Container(height: 100, color: Colors.green[200]),
                  
                  // Buildings
                  Positioned(
                    left: 20,
                    bottom: 80,
                    child: _buildBuildingIcon(Icons.factory, _powerPlantLevel, 'الطاقة'),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 80,
                    child: _buildBuildingIcon(Icons.directions_bus, _transportLevel, 'النقل'),
                  ),
                  Positioned(
                    bottom: 120,
                    child: _buildBuildingIcon(Icons.delete_outline, _wasteLevel, 'النفايات'),
                  ),
                ],
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تطوير البنية التحتية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildUpgradeButton('محطة الطاقة', 'power', _powerPlantLevel, 300),
                const SizedBox(height: 8),
                _buildUpgradeButton('شبكة النقل', 'transport', _transportLevel, 250),
                const SizedBox(height: 8),
                _buildUpgradeButton('إدارة النفايات', 'waste', _wasteLevel, 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingIcon(IconData icon, int level, String label) {
    Color color = level == 0 ? Colors.grey : (level == 1 ? Colors.orange : Colors.green);
    return Column(
      children: [
        Icon(icon, size: 60, color: color),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(String label, String type, int currentLevel, int baseCost) {
    int cost = (currentLevel + 1) * baseCost;
    bool isMax = currentLevel >= 2;
    bool canAfford = _budget >= cost;

    return ElevatedButton(
      onPressed: isMax || !canAfford ? null : () => _upgradeBuilding(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            if (isMax)
              const Text('مكتمل', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
            else
              Text('\$$cost', style: TextStyle(color: canAfford ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}
