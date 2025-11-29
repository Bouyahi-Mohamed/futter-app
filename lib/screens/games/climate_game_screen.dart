import 'package:flutter/material.dart';
import '../../widgets/character_animator.dart';

class ClimateGameScreen extends StatefulWidget {
  const ClimateGameScreen({super.key});

  @override
  State<ClimateGameScreen> createState() => _ClimateGameScreenState();
}

class _ClimateGameScreenState extends State<ClimateGameScreen> {
  int _co2Level = 50;
  int _economy = 50;
  int _publicSupport = 50;

  // Region Data
  final List<_Region> _regions = [
    _Region(
      id: 'industry',
      title: 'مراكز الصناعة',
      icon: Icons.factory,
      color: Colors.grey,
      top: 0.2,
      left: 0.2,
      cards: [
        _PolicyCard(
          title: 'ضريبة الكربون',
          description: 'فرض ضريبة عالية على المصانع الملوثة.',
          yesEffect: _GameStats(co2: -10, economy: -5, support: -2),
          noEffect: _GameStats(co2: 5, economy: 2, support: 0),
        ),
        _PolicyCard(
          title: 'دعم التكنولوجيا النظيفة',
          description: 'تقديم منح للمصانع للتحول للأخضر.',
          yesEffect: _GameStats(co2: -8, economy: -2, support: 5),
          noEffect: _GameStats(co2: 2, economy: 0, support: -2),
        ),
      ],
    ),
    _Region(
      id: 'energy',
      title: 'شبكة الطاقة',
      icon: Icons.bolt,
      color: Colors.amber,
      top: 0.3,
      left: 0.7,
      cards: [
        _PolicyCard(
          title: 'دعم الطاقة الشمسية',
          description: 'حوافز لتركيب الألواح الشمسية.',
          yesEffect: _GameStats(co2: -15, economy: -5, support: 10),
          noEffect: _GameStats(co2: 5, economy: 0, support: -5),
        ),
      ],
    ),
    _Region(
      id: 'disaster',
      title: 'بؤر الكوارث',
      icon: Icons.warning,
      color: Colors.red,
      top: 0.6,
      left: 0.3,
      cards: [
        _PolicyCard(
          title: 'نظام الإنذار المبكر',
          description: 'تطوير أنظمة رصد الفيضانات.',
          yesEffect: _GameStats(co2: 0, economy: -5, support: 15),
          noEffect: _GameStats(co2: 0, economy: 0, support: -10),
        ),
      ],
    ),
    _Region(
      id: 'hotspots',
      title: 'النقاط الساخنة',
      icon: Icons.nature,
      color: Colors.green,
      top: 0.7,
      left: 0.8,
      cards: [
        _PolicyCard(
          title: 'محميات طبيعية',
          description: 'حظر الصيد وقطع الأشجار.',
          yesEffect: _GameStats(co2: -5, economy: -2, support: 5),
          noEffect: _GameStats(co2: 5, economy: 2, support: -5),
        ),
      ],
    ),
  ];

  void _openRegion(BuildContext context, _Region region) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _RegionSheet(
        region: region,
        onDecision: (stats) {
          setState(() {
            _co2Level = (_co2Level + stats.co2).clamp(0, 100);
            _economy = (_economy + stats.economy).clamp(0, 100);
            _publicSupport = (_publicSupport + stats.support).clamp(0, 100);
          });
          Navigator.pop(context);
          _checkWinCondition();
        },
      ),
    );
  }

  void _checkWinCondition() {
    if (_co2Level < 30 && _economy > 60 && _publicSupport > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أداء ممتاز! العالم في أمان.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخريطة الاستراتيجية')),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('CO2', _co2Level, Colors.red),
                _buildStat('الاقتصاد', _economy, Colors.green),
                _buildStat('الشعبية', _publicSupport, Colors.blue),
              ],
            ),
          ),
          
          // Map Area
          Expanded(
            child: Stack(
              children: [
                // Map Background
                Container(
                  color: Colors.blue[50],
                  child: Center(
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(Icons.public, size: 300, color: Colors.blue[200]),
                    ),
                  ),
                ),
                
                // Regions
                ..._regions.map((region) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.6 * region.top, // Adjust scale
                    left: MediaQuery.of(context).size.width * region.left,
                    child: GestureDetector(
                      onTap: () => _openRegion(context, region),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: region.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(region.icon, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              region.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Character (Leader)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: CharacterAnimator(
                    isWalking: false,
                    size: 120,
                    outfit: CharacterOutfit.strategy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$value%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}

class _RegionSheet extends StatefulWidget {
  final _Region region;
  final Function(_GameStats) onDecision;

  const _RegionSheet({required this.region, required this.onDecision});

  @override
  State<_RegionSheet> createState() => _RegionSheetState();
}

class _RegionSheetState extends State<_RegionSheet> {
  int _currentCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    final card = widget.region.cards[_currentCardIndex];
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.region.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            card.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(card.description),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => widget.onDecision(card.noEffect),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100], foregroundColor: Colors.red),
                child: const Text('رفض'),
              ),
              ElevatedButton(
                onPressed: () => widget.onDecision(card.yesEffect),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100], foregroundColor: Colors.green),
                child: const Text('موافقة'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Region {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final double top;
  final double left;
  final List<_PolicyCard> cards;

  _Region({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.top,
    required this.left,
    required this.cards,
  });
}

class _PolicyCard {
  final String title;
  final String description;
  final _GameStats yesEffect;
  final _GameStats noEffect;

  _PolicyCard({
    required this.title,
    required this.description,
    required this.yesEffect,
    required this.noEffect,
  });
}

class _GameStats {
  final int co2;
  final int economy;
  final int support;

  _GameStats({required this.co2, required this.economy, required this.support});
}
