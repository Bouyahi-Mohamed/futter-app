import 'package:flutter/material.dart';
import '../../widgets/character_animator.dart';
import 'city_sectors/energy_sector_screen.dart';
import 'city_sectors/waste_sector_screen.dart';
import 'city_sectors/transport_sector_screen.dart';
import 'city_sectors/agriculture_sector_screen.dart';

class CityGameMapScreen extends StatefulWidget {
  const CityGameMapScreen({super.key});

  @override
  State<CityGameMapScreen> createState() => _CityGameMapScreenState();
}

class _CityGameMapScreenState extends State<CityGameMapScreen> {
  int _currentSector = 1;
  int _budget = 5000;
  int _sustainability = 30;
  int _happiness = 50;

  final List<_SectorNode> _sectors = [
    _SectorNode(
      id: 1,
      title: 'منطقة الطاقة',
      subtitle: 'طاقة متجددة',
      icon: Icons.bolt,
      color: Colors.amber[700]!,
      top: 0.25,
      left: 0.2,
      unlocked: true,
    ),
    _SectorNode(
      id: 2,
      title: 'إدارة النفايات',
      subtitle: 'إعادة التدوير',
      icon: Icons.recycling,
      color: Colors.green[700]!,
      top: 0.25,
      left: 0.7,
      unlocked: false,
    ),
    _SectorNode(
      id: 3,
      title: 'النقل المستدام',
      subtitle: 'مواصلات خضراء',
      icon: Icons.directions_subway,
      color: Colors.blue[700]!,
      top: 0.65,
      left: 0.35,
      unlocked: false,
    ),
    _SectorNode(
      id: 4,
      title: 'الزراعة الحضرية',
      subtitle: 'إنتاج محلي',
      icon: Icons.agriculture,
      color: Colors.lightGreen[700]!,
      top: 0.65,
      left: 0.75,
      unlocked: false,
    ),
  ];

  void _unlockNextSector() {
    setState(() {
      if (_currentSector < _sectors.length) {
        _currentSector++;
        _sectors[_currentSector - 1].unlocked = true;
      }
    });
  }

  void _updateCityStats(int budgetDelta, int sustainabilityDelta, int happinessDelta) {
    setState(() {
      _budget = (_budget + budgetDelta).clamp(0, 10000);
      _sustainability = (_sustainability + sustainabilityDelta).clamp(0, 100);
      _happiness = (_happiness + happinessDelta).clamp(0, 100);
    });
  }

  void _navigateToSector(_SectorNode sector) {
    if (!sector.unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل القطاع السابق أولاً!')),
      );
      return;
    }

    Widget? sectorScreen;
    switch (sector.id) {
      case 1:
        sectorScreen = EnergySectorScreen(
          onComplete: _unlockNextSector,
          onStatsUpdate: _updateCityStats,
        );
        break;
      case 2:
        sectorScreen = WasteSectorScreen(
          onComplete: _unlockNextSector,
          onStatsUpdate: _updateCityStats,
        );
        break;
      case 3:
        sectorScreen = TransportSectorScreen(
          onComplete: _unlockNextSector,
          onStatsUpdate: _updateCityStats,
        );
        break;
      case 4:
        sectorScreen = AgricultureSectorScreen(
          onComplete: _unlockNextSector,
          onStatsUpdate: _updateCityStats,
        );
        break;
    }

    if (sectorScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => sectorScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المدينة المستدامة'),
        backgroundColor: Colors.teal[700],
      ),
      body: Stack(
        children: [
          // Background - City grid
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[200]!, Colors.grey[300]!, Colors.grey[400]!],
              ),
            ),
          ),

          // Connection paths between sectors
          CustomPaint(
            size: Size.infinite,
            painter: _PathPainter(_sectors),
          ),

          // Sector Nodes
          ..._sectors.map((sector) {
            return Positioned(
              top: MediaQuery.of(context).size.height * sector.top,
              left: MediaQuery.of(context).size.width * sector.left - 70,
              child: GestureDetector(
                onTap: () => _navigateToSector(sector),
                child: Column(
                  children: [
                    // Sector Node
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: sector.unlocked ? sector.color : Colors.grey[500],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: _currentSector == sector.id
                              ? Colors.yellow
                              : Colors.white,
                          width: 5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            sector.icon,
                            size: 60,
                            color: Colors.white,
                          ),
                          if (!sector.unlocked)
                            const Icon(
                              Icons.lock,
                              size: 35,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sector Info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            sector.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            sector.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Character (Mayor)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height *
                    _sectors.firstWhere((s) => s.id == _currentSector).top -
                80,
            left: MediaQuery.of(context).size.width *
                    _sectors.firstWhere((s) => s.id == _currentSector).left -
                30,
            child: const CharacterAnimator(
              isWalking: false,
              size: 90,
              outfit: CharacterOutfit.city,
            ),
          ),

          // City Stats Panel
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات المدينة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow('💰 الميزانية', '\$$_budget', Colors.green),
                  _buildStatRow('♻️ الاستدامة', '$_sustainability%', Colors.teal),
                  _buildStatRow('😊 السعادة', '$_happiness%', Colors.orange),
                  const SizedBox(height: 8),
                  Text('القطاع: $_currentSector / ${_sectors.length}'),
                ],
              ),
            ),
          ),



          // Debug unlock button
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _unlockNextSector,
              backgroundColor: Colors.orange,
              mini: true,
              child: const Icon(Icons.lock_open),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectorNode {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double top;
  final double left;
  bool unlocked;

  _SectorNode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.top,
    required this.left,
    required this.unlocked,
  });
}

class _PathPainter extends CustomPainter {
  final List<_SectorNode> sectors;
  _PathPainter(this.sectors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw connections between sectors
    for (int i = 0; i < sectors.length - 1; i++) {
      final start = Offset(
        size.width * sectors[i].left,
        size.height * sectors[i].top,
      );
      final end = Offset(
        size.width * sectors[i + 1].left,
        size.height * sectors[i + 1].top,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
