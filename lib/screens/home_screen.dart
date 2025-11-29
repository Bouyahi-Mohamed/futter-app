import 'package:flutter/material.dart';
import '../models/game_data.dart';
import 'game_detail_screen.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'games/hero_game_screen.dart';
import 'games/climate_game_screen.dart';
import 'games/city_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('أبطال البيئة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'خريطة العالم',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MapScreen()),
          );
        },
        label: const Text('ابدأ الرحلة'),
        icon: const Icon(Icons.map),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gamesList.length,
        itemBuilder: (context, index) {
          final game = gamesList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameDetailScreen(game: game),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.videogame_asset, // Placeholder icon
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                game.category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GameDetailScreen(game: game),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('التفاصيل'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Widget? gameScreen;
                            if (game.title.contains('البطل البيئي')) {
                              gameScreen = const HeroGameScreen();
                            } else if (game.title.contains('مكافحة تغير المناخ')) {
                              gameScreen = const ClimateGameScreen();
                            } else if (game.title.contains('تحدي المدينة المستدامة')) {
                              gameScreen = const CityGameScreen();
                            }

                            if (gameScreen != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => gameScreen!),
                              );
                            }
                          },
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('فتح الخريطة'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
