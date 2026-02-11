import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/assessments_list_screen.dart';
import 'package:crimpy/views/screens/profile_screen/profile_screen.dart';
import 'package:crimpy/views/widgets/ble/tare_dialog.dart';
import 'package:crimpy/views/screens/chart_screen.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/trainings_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/views/screens/home_screen/home_screen.dart';
import 'package:crimpy/views/screens/settings_screen/settings_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../viewmodels/ble_view_model.dart';
import '../viewmodels/app_info_view_model.dart';
import 'widgets/ble/connection_dialog.dart';
import 'widgets/whats_new_dialog.dart';

// Custom navigation destination widget to reduce rebuilds
class _NavDestination extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavDestination({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return NavigationDestination(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int currentPageIndex = 0;
  final _pageViewController = PageController();

  @override
  void initState() {
    super.initState();
    // Check if we should show the "What's New" dialog after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  /// Check if the app has been updated and show the "What's New" dialog
  Future<void> _checkForUpdates() async {
    final whatsNewManager = ref.read(whatsNewProvider);
    final shouldShow = await whatsNewManager.shouldShowWhatsNew();

    if (shouldShow && mounted) {
      await showDialog(
        context: context,
        builder: (context) => const WhatsNewDialog(),
      );
      // Mark this version as seen
      await whatsNewManager.markVersionSeen();
    }
  }

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
            _pageViewController.jumpToPage(index);
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
            _NavDestination(
              icon: FontAwesomeIcons.house,
              label: 'Home',
              isSelected: currentPageIndex == 0,
            ),
            _NavDestination(
              icon: FontAwesomeIcons.fire,
              label: 'Trainings',
              isSelected: currentPageIndex == 1,
            ),
            _NavDestination(
              icon: FontAwesomeIcons.chartSimple,
              label: 'Assessments',
              isSelected: currentPageIndex == 2,
            ),
            _NavDestination(
              icon: FontAwesomeIcons.user,
              label: 'Profile',
              isSelected: currentPageIndex == 3,
            ),
            _NavDestination(
              icon: FontAwesomeIcons.gear,
              label: 'Settings',
              isSelected: currentPageIndex == 4,
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
      body: PageView(
        controller: _pageViewController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: <Widget>[
          HomeScreen(),
          TrainingScreen(
            goToAssessments: () => _pageViewController.jumpToPage(2),
          ),
          AssessmentsScreen(),
          ClimbingProfileScreen(),
          SettingsScreen(),
        ],
      ),
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
