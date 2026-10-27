import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/owner_booking_provider.dart';
import '../../theme/app_theme.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<OwnerBookingProvider>(
        context,
        listen: false,
      ).getOwnerBookings();
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

  String formatDate(dynamic date) {
    if (date == null) return '';
    try {
      DateTime d = DateTime.parse(date.toString());
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Partner Bookings')),
      body: Consumer<OwnerBookingProvider>(
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
                    'No Booking Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'New customer rental requests will appear here.',
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.getOwnerBookings,
            color: AppColors.turmeric,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                final booking = provider.bookings[index];
                final status = (booking['status'] ?? 'pending').toString();
                final statusClr = _statusColor(status);
                final statusBg = _statusBgColor(status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: AppColors.maltBorder.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking['vehicleName'] ?? 'Vehicle',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.malt,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusClr,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.maltMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${formatDate(booking['startDate'])} - ${formatDate(booking['endDate'])}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.malt,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${booking['numberOfDays'] ?? 0} day(s)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.maltMuted,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Revenue:',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.maltMuted,
                              ),
                            ),
                            Text(
                              '₹${booking['totalAmount'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.malt,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment Status:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.maltMuted,
                              ),
                            ),
                            Text(
                              (booking['paymentStatus'] ?? 'pending')
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:
                                    (booking['paymentStatus'] ?? '')
                                            .toString()
                                            .toLowerCase() ==
                                        'completed'
                                    ? Colors.green.shade700
                                    : AppColors.malt,
                              ),
                            ),
                          ],
                        ),

                        if (status.toLowerCase() == 'pending') ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.updateBookingStatus(
                                      bookingId: booking['id'],
                                      status: 'confirmed',
                                    );
                                  },
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Accept Request'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  onPressed: () {
                                    provider.updateBookingStatus(
                                      bookingId: booking['id'],
                                      status: 'rejected',
                                    );
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Decline'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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
