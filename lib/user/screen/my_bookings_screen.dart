import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/booking_provider.dart';
import '../model/booking_model.dart';
import '../../theme/app_theme.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<BookingProvider>(context, listen: false).getMyBookings();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        return AppColors.successLight;
      case 'rejected':
      case 'cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.turmeric),
            );
          }

          if (provider.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: AppColors.turmericLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.book_online_outlined,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Bookings Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your vehicle reservations will appear here.',
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.getMyBookings,
            color: AppColors.turmeric,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                BookingModel booking = provider.bookings[index];
                final statusClr = _statusColor(booking.status);
                final statusBg = _statusBgColor(booking.status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.maltBorder.withValues(alpha: 0.7),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingDetailsScreen(booking: booking),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.malt,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              color: AppColors.turmeric,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.vehicleName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.malt,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking.shopName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.maltMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${booking.totalAmount.toStringAsFixed(0)} • ${booking.numberOfDays} day(s)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.malt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusClr,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
