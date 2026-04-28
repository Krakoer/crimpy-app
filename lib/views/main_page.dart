import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/sync_view_model.dart';
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
// import '../viewmodels/app_info_view_model.dart';
import 'widgets/ble/connection_dialog.dart';
// import 'widgets/whats_new_dialog.dart';

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isSelected
        ? primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 2,
              color: isSelected ? primary : Colors.transparent,
            ),
            const SizedBox(height: 10),
            FaIcon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with WidgetsBindingObserver {
  int currentPageIndex = 0;
  final _pageViewController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _checkForUpdates();
      _syncOnStartup();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final user = ref.read(authStateProvider).asData?.value;
      if (user != null) {
        ref.read(syncViewModelProvider.notifier).performSyncSilently();
      }
    }
  }

  void _syncOnStartup() {
    final user = ref.read(authStateProvider).asData?.value;
    if (user != null) {
      ref.read(syncViewModelProvider.notifier).performSyncSilently();
    }
  }

  /// Check if the app has been updated and show the "What's New" dialog
  // Future<void> _checkForUpdates() async {
  //   final whatsNewManager = ref.read(whatsNewProvider);
  //   final shouldShow = await whatsNewManager.shouldShowWhatsNew();

  //   if (shouldShow && mounted) {
  //     await showDialog(
  //       context: context,
  //       builder: (context) => const WhatsNewDialog(),
  //     );
  //     // Mark this version as seen
  //     await whatsNewManager.markVersionSeen();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              _NavItem(
                icon: FontAwesomeIcons.house,
                label: 'Home',
                isSelected: currentPageIndex == 0,
                onTap: () => _pageViewController.jumpToPage(0),
              ),
              _NavItem(
                icon: FontAwesomeIcons.fire,
                label: 'Trainings',
                isSelected: currentPageIndex == 1,
                onTap: () => _pageViewController.jumpToPage(1),
              ),
              _NavItem(
                icon: FontAwesomeIcons.chartSimple,
                label: 'Assess.',
                isSelected: currentPageIndex == 2,
                onTap: () => _pageViewController.jumpToPage(2),
              ),
              _NavItem(
                icon: FontAwesomeIcons.user,
                label: 'Profile',
                isSelected: currentPageIndex == 3,
                onTap: () => _pageViewController.jumpToPage(3),
              ),
              _NavItem(
                icon: FontAwesomeIcons.gear,
                label: 'Settings',
                isSelected: currentPageIndex == 4,
                onTap: () => _pageViewController.jumpToPage(4),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          const [
            'Crimpy',
            'Trainings',
            'Assessments',
            'Profile',
            'Settings',
          ][currentPageIndex],
        ),
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
          ClimbingProfileScreen(
            goToAssessments: () => _pageViewController.jumpToPage(2),
          ),
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
