import 'package:flutter/material.dart';
import '../../widgets/character_animator.dart';

class CityGameScreen extends StatefulWidget {
  const CityGameScreen({super.key});

  @override
  State<CityGameScreen> createState() => _CityGameScreenState();
}

class _CityGameScreenState extends State<CityGameScreen> {
  int _budget = 1000;
  int _sustainabilityScore = 20;

  final List<_Sector> _sectors = [
    _Sector(
      id: 'energy',
      title: 'قطاع الطاقة',
      icon: Icons.bolt,
      color: Colors.amber,
      currentLevel: 1,
      maxLevel: 3,
      upgrades: [
        _Upgrade(name: 'محطة فحم', cost: 0, sustainability: 10),
        _Upgrade(name: 'غاز طبيعي', cost: 200, sustainability: 30),
        _Upgrade(name: 'طاقة شمسية', cost: 500, sustainability: 80),
      ],
    ),
    _Sector(
      id: 'waste',
      title: 'إدارة النفايات',
      icon: Icons.delete_outline,
      color: Colors.brown,
      currentLevel: 1,
      maxLevel: 3,
      upgrades: [
        _Upgrade(name: 'مكب نفايات', cost: 0, sustainability: 5),
        _Upgrade(name: 'فرز النفايات', cost: 150, sustainability: 40),
        _Upgrade(name: 'إعادة تدوير شامل', cost: 400, sustainability: 90),
      ],
    ),
    _Sector(
      id: 'transport',
      title: 'النقل المستدام',
      icon: Icons.directions_bus,
      color: Colors.blue,
      currentLevel: 1,
      maxLevel: 3,
      upgrades: [
        _Upgrade(name: 'سيارات خاصة', cost: 0, sustainability: 10),
        _Upgrade(name: 'حافلات عامة', cost: 100, sustainability: 50),
        _Upgrade(name: 'مترو أنفاق', cost: 600, sustainability: 95),
      ],
    ),
    _Sector(
      id: 'agriculture',
      title: 'الزراعة الحضرية',
      icon: Icons.local_florist,
      color: Colors.green,
      currentLevel: 1,
      maxLevel: 3,
      upgrades: [
        _Upgrade(name: 'حدائق صغيرة', cost: 0, sustainability: 15),
        _Upgrade(name: 'أسطح خضراء', cost: 150, sustainability: 60),
        _Upgrade(name: 'مزارع عمودية', cost: 450, sustainability: 100),
      ],
    ),
  ];

  void _upgradeSector(_Sector sector) {
    if (sector.currentLevel < sector.maxLevel) {
      final nextUpgrade = sector.upgrades[sector.currentLevel];
      if (_budget >= nextUpgrade.cost) {
        setState(() {
          _budget -= nextUpgrade.cost;
          _sustainabilityScore += (nextUpgrade.sustainability - sector.upgrades[sector.currentLevel - 1].sustainability);
          sector.currentLevel++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تطوير ${sector.title} بنجاح!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الميزانية غير كافية!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحدي المدينة المستدامة')),
      body: Column(
        children: [
          // Stats Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('الميزانية', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$$_budget', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                CharacterAnimator(isWalking: false, size: 80, outfit: CharacterOutfit.city),
                Column(
                  children: [
                    const Text('الاستدامة', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_sustainabilityScore%', style: const TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          // Grid Map
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _sectors.length,
              itemBuilder: (context, index) {
                final sector = _sectors[index];
                final currentUpgrade = sector.upgrades[sector.currentLevel - 1];
                final nextUpgrade = sector.currentLevel < sector.maxLevel ? sector.upgrades[sector.currentLevel] : null;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(sector.icon, size: 48, color: sector.color),
                        const SizedBox(height: 8),
                        Text(sector.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(currentUpgrade.name, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const Spacer(),
                        if (nextUpgrade != null)
                          ElevatedButton(
                            onPressed: () => _upgradeSector(sector),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sector.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Column(
                              children: [
                                const Text('تطوير'),
                                Text('\$${nextUpgrade.cost}', style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          )
                        else
                          const Chip(
                            label: Text('مكتمل'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Sector {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  int currentLevel;
  final int maxLevel;
  final List<_Upgrade> upgrades;

  _Sector({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.currentLevel,
    required this.maxLevel,
    required this.upgrades,
  });
}

class _Upgrade {
  final String name;
  final int cost;
  final int sustainability;

  _Upgrade({required this.name, required this.cost, required this.sustainability});
}
