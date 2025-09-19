import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/assessments_list_screen.dart';
import 'package:crimpy/views/screens/profile_screen/profile_screen.dart';
import 'package:crimpy/views/widgets/ble/tare_dialog.dart';
import 'package:crimpy/views/screens/chart_screen.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/views/screens/home_screen/home_screen.dart';
import 'package:crimpy/views/screens/settings_screen/settings_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../viewmodels/ble_view_model.dart';
import 'widgets/ble/connection_dialog.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 2,
            ),
          ),
        ),
        child: NavigationBar(
          height: 60,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          destinations: <Widget>[
            NavigationDestination(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    size: 20,
                    color:
                        currentPageIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          currentPageIndex == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.dumbbell,
                    size: 20,
                    color:
                        currentPageIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          currentPageIndex == 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              label: 'Trainings',
            ),
            NavigationDestination(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.ruler,
                    size: 20,
                    color:
                        currentPageIndex == 2
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          currentPageIndex == 2
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              label: 'Assessments',
            ),
            NavigationDestination(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.solidCircleUser,
                    size: 20,
                    color:
                        currentPageIndex == 3
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          currentPageIndex == 3
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings,
                    size: 20,
                    color:
                        currentPageIndex == 4
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          currentPageIndex == 4
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Crimpy"),
        actions: [
          // Live data button when connected
          IconButton(
            onPressed:
                ref.watch(connectionStateProvider) !=
                        BleConnectionState.connected
                    ? null
                    : () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => ChartScreen())),
            icon: Icon(FontAwesomeIcons.chartLine),
          ),
          // Connection status icon in app bar
          IconButton(
            icon: Icon(_getConnectionIcon(connectionState)),
            onPressed: () => _showConnectionDialog(context),
          ),
        ],
      ),
      body:
          <Widget>[
            HomeScreen(),
            TrainingScreen(
              goToAssessments:
                  () => setState(() {
                    currentPageIndex = 2;
                  }),
            ),
            AssessmentsScreen(),
            ClimbingProfileScreen(),
            SettingsScreen(),
          ][currentPageIndex],
    );
  }

  IconData _getConnectionIcon(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return Icons.bluetooth_connected;
      case BleConnectionState.connecting:
        return Icons.bluetooth_searching;
      case BleConnectionState.failed:
        return Icons.bluetooth_disabled;
      case BleConnectionState.disconnected:
        return Icons.bluetooth_disabled;
    }
  }

  void _showConnectionDialog(BuildContext context) async {
    final isConnected = await showDialog(
      context: context,
      builder: (context) => const ConnectionDialog(),
    );
    if (isConnected != null && isConnected && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => const TareDialog(),
        barrierDismissible: false,
      );
    }
  }
}
