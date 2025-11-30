import 'package:flutter/material.dart';
import '../../widgets/character_animator.dart';
import 'climate_levels/industry_region_screen.dart';
import 'climate_levels/energy_region_screen.dart';
import 'climate_levels/disaster_region_screen.dart';
import 'climate_levels/hotspot_region_screen.dart';

class ClimateGameMapScreen extends StatefulWidget {
  const ClimateGameMapScreen({super.key});

  @override
  State<ClimateGameMapScreen> createState() => _ClimateGameMapScreenState();
}

class _ClimateGameMapScreenState extends State<ClimateGameMapScreen> {
  int _currentRegion = 1;
  
  // Global stats
  int _co2Level = 50;
  int _economy = 50;
  int _publicSupport = 50;

  final List<_RegionNode> _regions = [
    _RegionNode(
      id: 1,
      title: 'مراكز الصناعة',
      subtitle: 'تحويل المصانع',
      icon: Icons.factory,
      color: Colors.grey[700]!,
      top: 0.75,
      left: 0.15,
      unlocked: true,
    ),
    _RegionNode(
      id: 2,
      title: 'شبكة الطاقة',
      subtitle: 'طاقة متجددة',
      icon: Icons.bolt,
      color: Colors.amber[700]!,
      top: 0.55,
      left: 0.4,
      unlocked: false,
    ),
    _RegionNode(
      id: 3,
      title: 'بؤر الكوارث',
      subtitle: 'أنظمة إنذار',
      icon: Icons.warning,
      color: Colors.red[700]!,
      top: 0.35,
      left: 0.65,
      unlocked: false,
    ),
    _RegionNode(
      id: 4,
      title: 'النقاط الساخنة',
      subtitle: 'محميات طبيعية',
      icon: Icons.nature,
      color: Colors.green[700]!,
      top: 0.15,
      left: 0.85,
      unlocked: false,
    ),
  ];

  void _unlockNextRegion() {
    setState(() {
      if (_currentRegion < _regions.length) {
        _currentRegion++;
        _regions[_currentRegion - 1].unlocked = true;
      }
    });
  }

  void _updateStats(int co2Delta, int economyDelta, int supportDelta) {
    setState(() {
      _co2Level = (_co2Level + co2Delta).clamp(0, 100);
      _economy = (_economy + economyDelta).clamp(0, 100);
      _publicSupport = (_publicSupport + supportDelta).clamp(0, 100);
    });
  }

  void _navigateToRegion(_RegionNode region) {
    if (!region.unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل المنطقة السابقة أولاً!')),
      );
      return;
    }

    Widget? regionScreen;
    switch (region.id) {
      case 1:
        regionScreen = IndustryRegionScreen(
          onComplete: _unlockNextRegion,
          onStatsUpdate: _updateStats,
        );
        break;
      case 2:
        regionScreen = EnergyRegionScreen(
          onComplete: _unlockNextRegion,
          onStatsUpdate: _updateStats,
        );
        break;
      case 3:
        regionScreen = DisasterRegionScreen(
          onComplete: _unlockNextRegion,
          onStatsUpdate: _updateStats,
        );
        break;
      case 4:
        regionScreen = HotspotRegionScreen(
          onComplete: _unlockNextRegion,
          onStatsUpdate: _updateStats,
        );
        break;
    }

    if (regionScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => regionScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة مكافحة تغير المناخ'),
        backgroundColor: Colors.blue[800],
      ),
      body: Stack(
        children: [
          // Background - World map style
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[200]!,
                  Colors.blue[100]!,
                  Colors.green[100]!,
                ],
              ),
            ),
          ),

          // Decorative world map outline
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: _WorldMapPainter(),
              ),
            ),
          ),

          // Connection lines between regions
          CustomPaint(
            size: Size.infinite,
            painter: _ConnectionPainter(_regions),
          ),

          // Region Nodes
          ..._regions.map((region) {
            return Positioned(
              top: MediaQuery.of(context).size.height * region.top,
              left: MediaQuery.of(context).size.width * region.left - 60,
              child: GestureDetector(
                onTap: () => _navigateToRegion(region),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: region.unlocked ? region.color : Colors.grey[400],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: _currentRegion == region.id
                              ? Colors.yellow
                              : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            region.icon,
                            size: 50,
                            color: Colors.white,
                          ),
                          if (!region.unlocked)
                            const Icon(
                              Icons.lock,
                              size: 30,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            region.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            region.subtitle,
                            style: TextStyle(
                              fontSize: 11,
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

          // Character (Leader)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height *
                    _regions.firstWhere((r) => r.id == _currentRegion).top -
                70,
            left: MediaQuery.of(context).size.width *
                    _regions.firstWhere((r) => r.id == _currentRegion).left -
                25,
            child: const CharacterAnimator(
              isWalking: true,
              size: 90,
              outfit: CharacterOutfit.adventure,
            ),
          ),

          // Global Stats Panel
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المؤشرات العالمية',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow('CO2', _co2Level, Colors.red),
                  _buildStatRow('الاقتصاد', _economy, Colors.green),
                  _buildStatRow('الشعبية', _publicSupport, Colors.blue),
                  const SizedBox(height: 8),
                  Text('المنطقة: $_currentRegion / ${_regions.length}'),
                ],
              ),
            ),
          ),

          // Debug unlock button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _unlockNextRegion,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.lock_open),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('$value%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RegionNode {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double top;
  final double left;
  bool unlocked;

  _RegionNode({
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

class _ConnectionPainter extends CustomPainter {
  final List<_RegionNode> regions;
  _ConnectionPainter(this.regions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < regions.length - 1; i++) {
      final start = Offset(
        size.width * regions[i].left,
        size.height * regions[i].top,
      );
      final end = Offset(
        size.width * regions[i + 1].left,
        size.height * regions[i + 1].top,
      );

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      }

      // Curved path
      final controlPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2 - 50, // Curve upwards
      );
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Simple continents outline
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.3, size.height * 0.4),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.3, size.width * 0.4, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
