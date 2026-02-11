import 'package:crimpy/views/screens/home_screen/history/week_histogram_card.dart';
import 'package:crimpy/views/screens/home_screen/favorite_training.dart';
import 'package:crimpy/views/screens/home_screen/widgets/log_session_buttons.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: [
            // Weekly session histogram.
            WeekHistogramCard(maxBarHeight: 75),
            // Log session buttons.
            LogSessionButtons(),
            // Favorite training list.
            FavoriteTrainingList(),
          ],
        ),
      ),
    );
  }
}
