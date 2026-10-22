import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'manage_users_screen.dart';
import 'manage_owners_screen.dart';
import 'pending_vehicles_screen.dart';
import 'manage_bookings_screen.dart';
import 'notifications_screen.dart';
import 'reviews_screen.dart';
import 'complaints_screen.dart';
import 'all_vehicles_screen.dart';
import '../../theme/app_theme.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AdminDashboardScreen(),
    ManageUsersScreen(),
    ManageOwnersScreen(),
    PendingVehiclesScreen(),
    AllVehiclesScreen(),
    ManageBookingsScreen(),
    AdminNotificationsScreen(),
    ReviewsScreen(),
    ComplaintsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.malt,
            selectedIndex: selectedIndex,
            indicatorColor: AppColors.turmeric,
            selectedIconTheme: const IconThemeData(color: AppColors.malt),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.turmeric,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.turmeric,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.malt,
                  size: 24,
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store_outlined),
                selectedIcon: Icon(Icons.store),
                label: Text('Owners'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.hourglass_top_outlined),
                selectedIcon: Icon(Icons.hourglass_full),
                label: Text('Pending'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_car_outlined),
                selectedIcon: Icon(Icons.directions_car_filled),
                label: Text('Vehicles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online_outlined),
                selectedIcon: Icon(Icons.book_online),
                label: Text('Bookings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Alerts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_outline),
                selectedIcon: Icon(Icons.star),
                label: Text('Reviews'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.report_problem_outlined),
                selectedIcon: Icon(Icons.report_problem),
                label: Text('Complaints'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.maltBorder),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
