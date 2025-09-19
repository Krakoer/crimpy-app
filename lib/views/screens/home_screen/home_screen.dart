import 'package:crimpy/views/screens/home_screen/history/week_histogram_card.dart';
import 'package:crimpy/views/screens/home_screen/favorite_training.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: [
            // Weekly session histogram.
            WeekHistogramCard(maxBarHeight: 75),
            // Favorite training list.
            FavoriteTrainingList(),
          ],
        ),
      ),
    );
  }
}
