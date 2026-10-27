import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/admin_provider.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int users = 0;
  int owners = 0;
  int vehicles = 0;
  int bookings = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    setState(() {
      loading = true;
    });

    final provider = Provider.of<AdminProvider>(context, listen: false);

    try {
      users = await provider.getUserCount();
      owners = await provider.getOwnerCount();
      vehicles = await provider.getVehicleCount();
      bookings = await provider.getBookingCount();
    } catch (_) {}

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _dashboardStatCard({
    required String title,
    required int value,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.maltBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.malt.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.malt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.turmeric, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.turmericLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.malt,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            loading ? '...' : value.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.malt,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.malt,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.maltMuted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Executive Overview'),
        actions: [
          IconButton(
            onPressed: loadCounts,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Metrics',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.malt, AppColors.maltLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.malt.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.turmeric,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PLATFORM COMMAND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.malt,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'System Analytics & Fleet Health',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time overview of users, partners, fleet availability and reservations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Key Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.malt,
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _dashboardStatCard(
                  title: 'Registered Users',
                  value: users,
                  icon: Icons.people_alt_rounded,
                  subtitle: 'Active consumer accounts',
                ),
                _dashboardStatCard(
                  title: 'Partner Shops',
                  value: owners,
                  icon: Icons.storefront_rounded,
                  subtitle: 'Verified rental vendors',
                ),
                _dashboardStatCard(
                  title: 'Fleet Vehicles',
                  value: vehicles,
                  icon: Icons.directions_car_rounded,
                  subtitle: 'Cars, bikes & customs',
                ),
                _dashboardStatCard(
                  title: 'Total Reservations',
                  value: bookings,
                  icon: Icons.book_online_rounded,
                  subtitle: 'Cumulative platform bookings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
