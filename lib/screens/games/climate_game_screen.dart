import 'package:flutter/material.dart';

class ClimateGameScreen extends StatefulWidget {
  const ClimateGameScreen({super.key});

  @override
  State<ClimateGameScreen> createState() => _ClimateGameScreenState();
}

class _ClimateGameScreenState extends State<ClimateGameScreen> {
  int _co2Level = 50;
  int _economy = 50;
  int _publicSupport = 50;
  int _currentCardIndex = 0;

  final List<_PolicyCard> _cards = [
    _PolicyCard(
      title: 'ضريبة الكربون',
      description: 'فرض ضريبة عالية على المصانع الملوثة.',
      yesEffect: _GameStats(co2: -20, economy: -10, support: -5),
      noEffect: _GameStats(co2: 10, economy: 5, support: 0),
    ),
    _PolicyCard(
      title: 'دعم الطاقة الشمسية',
      description: 'تقديم حوافز مالية لتركيب الألواح الشمسية.',
      yesEffect: _GameStats(co2: -15, economy: -5, support: 10),
      noEffect: _GameStats(co2: 5, economy: 0, support: -5),
    ),
    _PolicyCard(
      title: 'حظر السيارات القديمة',
      description: 'منع السيارات التي تعمل بالديزل من دخول المدن.',
      yesEffect: _GameStats(co2: -10, economy: -5, support: -15),
      noEffect: _GameStats(co2: 5, economy: 0, support: 5),
    ),
    _PolicyCard(
      title: 'حملة تشجير وطنية',
      description: 'زراعة مليون شجرة في المناطق الصحراوية.',
      yesEffect: _GameStats(co2: -10, economy: -2, support: 15),
      noEffect: _GameStats(co2: 0, economy: 0, support: -5),
    ),
    _PolicyCard(
      title: 'إغلاق محطات الفحم',
      description: 'الاستغناء عن الفحم كمصدر للطاقة.',
      yesEffect: _GameStats(co2: -25, economy: -15, support: 5),
      noEffect: _GameStats(co2: 15, economy: 5, support: -5),
    ),
  ];

  void _makeDecision(bool accepted) {
    setState(() {
      final card = _cards[_currentCardIndex];
      final effect = accepted ? card.yesEffect : card.noEffect;

      _co2Level = (_co2Level + effect.co2).clamp(0, 100);
      _economy = (_economy + effect.economy).clamp(0, 100);
      _publicSupport = (_publicSupport + effect.support).clamp(0, 100);

      if (_currentCardIndex < _cards.length - 1) {
        _currentCardIndex++;
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    String message = '';
    if (_co2Level < 30 && _economy > 30 && _publicSupport > 30) {
      message = 'ممتاز! لقد حققت توازناً رائعاً وأنقذت البيئة.';
    } else if (_co2Level > 70) {
      message = 'للأسف، مستويات التلوث مرتفعة جداً.';
    } else if (_economy < 20) {
      message = 'لقد انهار الاقتصاد، حاول الموازنة أكثر.';
    } else {
      message = 'أداء جيد، ولكن يمكن تحسين القرارات.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('نتيجة القيادة'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('خروج'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _co2Level = 50;
                _economy = 50;
                _publicSupport = 50;
                _currentCardIndex = 0;
              });
            },
            child: const Text('حاول مجدداً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مكافحة تغير المناخ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('CO2', _co2Level, Colors.red, true),
                _buildStat('الاقتصاد', _economy, Colors.green, false),
                _buildStat('الشعبية', _publicSupport, Colors.blue, false),
              ],
            ),
            const SizedBox(height: 32),
            
            // Card Area
            Expanded(
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _cards[_currentCardIndex].title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _cards[_currentCardIndex].description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _makeDecision(false),
                              icon: const Icon(Icons.close),
                              label: const Text('رفض'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                foregroundColor: Colors.red,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _makeDecision(true),
                              icon: const Icon(Icons.check),
                              label: const Text('موافقة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade100,
                                foregroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'قرار ${_currentCardIndex + 1} من ${_cards.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color, bool isBadHigh) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              color: color,
            ),
            Text('$value%'),
          ],
        ),
      ],
    );
  }
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
