import 'package:flutter/material.dart';
import '../../../widgets/character_animator.dart';

class IndustryRegionScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int co2, int economy, int support)? onStatsUpdate;

  const IndustryRegionScreen({
    super.key,
    this.onComplete,
    this.onStatsUpdate,
  });

  @override
  State<IndustryRegionScreen> createState() => _IndustryRegionScreenState();
}

class _IndustryRegionScreenState extends State<IndustryRegionScreen> {
  int _currentDecision = 0;
  int _pollution = 80;
  int _unemployment = 30;
  bool _isPlaying = false;

  final List<_Decision> _decisions = [
    _Decision(
      title: 'ضريبة الكربون',
      description: 'فرض ضريبة عالية على المصانع الملوثة',
      challenge: 'مقاومة الشركات الكبرى',
      yesEffect: _Effect(co2: -15, economy: -10, support: -5, pollution: -20, unemployment: 5),
      noEffect: _Effect(co2: 5, economy: 2, support: 0, pollution: 10, unemployment: 0),
    ),
    _Decision(
      title: 'دعم التكنولوجيا النظيفة',
      description: 'تقديم منح للمصانع للتحول للطاقة الخضراء',
      challenge: 'تكلفة عالية على الميزانية',
      yesEffect: _Effect(co2: -12, economy: -5, support: 10, pollution: -15, unemployment: -3),
      noEffect: _Effect(co2: 3, economy: 0, support: -5, pollution: 5, unemployment: 0),
    ),
    _Decision(
      title: 'إغلاق المصانع الملوثة',
      description: 'إغلاق المصانع التي تتجاوز حدود الانبعاثات',
      challenge: 'زيادة معدل البطالة',
      yesEffect: _Effect(co2: -20, economy: -15, support: 5, pollution: -30, unemployment: 15),
      noEffect: _Effect(co2: 8, economy: 3, support: -10, pollution: 15, unemployment: 0),
    ),
  ];

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _currentDecision = 0;
      _pollution = 80;
      _unemployment = 30;
    });
  }

  void _makeDecision(bool accepted) {
    final decision = _decisions[_currentDecision];
    final effect = accepted ? decision.yesEffect : decision.noEffect;

    setState(() {
      _pollution = (_pollution + effect.pollution).clamp(0, 100);
      _unemployment = (_unemployment + effect.unemployment).clamp(0, 100);
    });

    // Update global stats
    widget.onStatsUpdate?.call(effect.co2, effect.economy, effect.support);

    if (_currentDecision < _decisions.length - 1) {
      setState(() {
        _currentDecision++;
      });
    } else {
      _endGame();
    }
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
    });

    final success = _pollution < 50 && _unemployment < 40;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : '⚠️ انتهت المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('مستوى التلوث: $_pollution%'),
            Text('معدل البطالة: $_unemployment%'),
            if (success) const Text('\nتم تحويل المصانع بنجاح!'),
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
          if (!success)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text('إعادة المحاولة'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراكز الصناعة 🏭'),
        backgroundColor: Colors.grey[800],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[400]!, Colors.grey[600]!, Colors.grey[800]!],
              ),
            ),
          ),

          // Factory silhouettes
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                painter: _FactoryPainter(),
              ),
            ),
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.factory, size: 100, color: Colors.white70),
                  const SizedBox(height: 20),
                  const Text(
                    'مراكز الصناعة',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
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
                        Text('• انبعاثات كربون عالية'),
                        Text('• مقاومة الشركات'),
                        SizedBox(height: 10),
                        Text('الأهداف:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('• تقليل التلوث < 50%'),
                        Text('• الحفاظ على البطالة < 40%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _decisions[_currentDecision].title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _decisions[_currentDecision].description,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'التحدي: ${_decisions[_currentDecision].challenge}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _makeDecision(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[100],
                            foregroundColor: Colors.red[900],
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('رفض'),
                        ),
                        ElevatedButton(
                          onPressed: () => _makeDecision(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            foregroundColor: Colors.green[900],
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('موافقة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    Text('🏭 التلوث: $_pollution%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('👷 البطالة: $_unemployment%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('${_currentDecision + 1}/${_decisions.length}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Decision {
  final String title;
  final String description;
  final String challenge;
  final _Effect yesEffect;
  final _Effect noEffect;

  _Decision({
    required this.title,
    required this.description,
    required this.challenge,
    required this.yesEffect,
    required this.noEffect,
  });
}

class _Effect {
  final int co2;
  final int economy;
  final int support;
  final int pollution;
  final int unemployment;

  _Effect({
    required this.co2,
    required this.economy,
    required this.support,
    required this.pollution,
    required this.unemployment,
  });
}

class _FactoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw simple factory shapes
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * 250.0, size.height - 150, 80, 150),
        paint,
      );
      // Chimney
      canvas.drawRect(
        Rect.fromLTWH(i * 250.0 + 30, size.height - 200, 20, 50),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
