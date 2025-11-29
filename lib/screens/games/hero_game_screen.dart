import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class HeroGameScreen extends StatefulWidget {
  const HeroGameScreen({super.key});

  @override
  State<HeroGameScreen> createState() => _HeroGameScreenState();
}

class _HeroGameScreenState extends State<HeroGameScreen> {
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _trashTimer;
  final List<_TrashItem> _trashItems = [];
  final Random _random = Random();
  bool _isPlaying = false;

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _trashItems.clear();
      _isPlaying = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });

    _trashTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_trashItems.length < 10) {
        _addTrash();
      }
    });
  }

  void _addTrash() {
    setState(() {
      _trashItems.add(
        _TrashItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          x: _random.nextDouble() * 300, // Approximate width constraint
          y: _random.nextDouble() * 500, // Approximate height constraint
          type: _random.nextBool() ? 'plastic' : 'paper',
        ),
      );
    });
  }

  void _collectTrash(String id) {
    setState(() {
      _trashItems.removeWhere((item) => item.id == id);
      _score += 10;
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _trashTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت اللعبة!'),
        content: Text('النتيجة النهائية: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to details
            },
            child: const Text('خروج'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('لعب مجدداً'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _trashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البطل البيئي'),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue.shade100, Colors.lightBlue.shade300],
              ),
            ),
          ),
          
          // Game Area
          if (_isPlaying)
            Stack(
              children: _trashItems.map((item) {
                return Positioned(
                  left: item.x,
                  top: item.y,
                  child: GestureDetector(
                    onTap: () => _collectTrash(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        item.type == 'plastic' ? Icons.local_drink : Icons.description,
                        color: item.type == 'plastic' ? Colors.blue : Colors.brown,
                        size: 32,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cleaning_services, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'نظف الشاطئ!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'اضغط على النفايات لجمعها قبل انتهاء الوقت',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('ابدأ اللعبة', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),

          // HUD
          if (_isPlaying)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'النقاط: $_score',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _timeLeft < 10 ? Colors.red.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الوقت: $_timeLeft',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _timeLeft < 10 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TrashItem {
  final String id;
  final double x;
  final double y;
  final String type;

  _TrashItem({required this.id, required this.x, required this.y, required this.type});
}
