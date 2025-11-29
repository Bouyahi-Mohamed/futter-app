import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DisasterRegionScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int co2, int economy, int support)? onStatsUpdate;

  const DisasterRegionScreen({super.key, this.onComplete, this.onStatsUpdate});

  @override
  State<DisasterRegionScreen> createState() => _DisasterRegionScreenState();
}

class _DisasterRegionScreenState extends State<DisasterRegionScreen> {
  bool _isPlaying = false;
  int _preparedness = 30;
  int _disastersStopped = 0;
  final int _disastersGoal = 5;
  int _timeLeft = 60;
  Timer? _gameTimer;
  Timer? _disasterTimer;
  
  final List<_Disaster> _activeDisasters = [];
  final Random _random = Random();

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _preparedness = 30;
      _disastersStopped = 0;
      _timeLeft = 60;
      _activeDisasters.clear();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame(false);
        }
      });
    });

    _disasterTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _spawnDisaster();
    });
  }

  void _spawnDisaster() {
    final types = ['flood', 'drought', 'storm'];
    setState(() {
      _activeDisasters.add(_Disaster(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: types[_random.nextInt(types.length)],
        x: _random.nextDouble() * 600,
        y: _random.nextDouble() * 400,
        severity: 1 + _random.nextInt(3),
      ));
    });
  }

  void _handleDisaster(_Disaster disaster) {
    setState(() {
      _activeDisasters.remove(disaster);
      _disastersStopped++;
      _preparedness = (_preparedness + 5).clamp(0, 100);
      
      if (_disastersStopped >= _disastersGoal) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool success) {
    _gameTimer?.cancel();
    _disasterTimer?.cancel();
    setState(() => _isPlaying = false);
    
    widget.onStatsUpdate?.call(0, -5, 15);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? '🎉 نجاح!' : '⏱️ انتهى الوقت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('كوارث تم إيقافها: $_disastersStopped / $_disastersGoal'),
            Text('مستوى التأهب: $_preparedness%'),
            if (success) const Text('\nتم تطوير أنظمة الإنذار!'),
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
  void dispose() {
    _gameTimer?.cancel();
    _disasterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بؤر الكوارث الطبيعية 🌪️'),
        backgroundColor: Colors.red[700],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.red[100]!, Colors.orange[100]!, Colors.yellow[100]!],
              ),
            ),
          ),

          if (!_isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 100, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'بؤر الكوارث الطبيعية',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('التحديات:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('• فيضانات - جفاف - عواصف'),
                        const SizedBox(height: 10),
                        const Text('الهدف:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('• إيقاف $_disastersGoal كوارث'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ المهمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
                ],
              ),
            )
          else
            Stack(
              children: [
                // Active disasters
                ..._activeDisasters.map((disaster) => Positioned(
                  left: disaster.x,
                  top: disaster.y,
                  child: GestureDetector(
                    onTap: () => _handleDisaster(disaster),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getDisasterColor(disaster.type),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getDisasterIcon(disaster.type),
                        color: Colors.white,
                        size: 30 + (disaster.severity * 10.0),
                      ),
                    ),
                  ),
                )),

                // Instructions
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'اضغط على الكوارث لإيقافها بأنظمة الإنذار!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
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
                    Text('⏱️ $_timeLeft ث', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('🛡️ تأهب: $_preparedness%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('✅ $_disastersStopped/$_disastersGoal', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getDisasterColor(String type) {
    switch (type) {
      case 'flood': return Colors.blue[700]!;
      case 'drought': return Colors.brown[700]!;
      case 'storm': return Colors.grey[700]!;
      default: return Colors.red;
    }
  }

  IconData _getDisasterIcon(String type) {
    switch (type) {
      case 'flood': return Icons.water;
      case 'drought': return Icons.wb_sunny;
      case 'storm': return Icons.cloud;
      default: return Icons.warning;
    }
  }
}

class _Disaster {
  final String id;
  final String type;
  final double x;
  final double y;
  final int severity;

  _Disaster({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.severity,
  });
}
