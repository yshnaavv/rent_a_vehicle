import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/booking_model.dart';
import '../provider/booking_provider.dart';
import '../../theme/app_theme.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

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
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.maltBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.malt.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.malt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      size: 38,
                      color: AppColors.turmeric,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    booking.vehicleName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusBgColor(booking.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(booking.status),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Reservation Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.malt,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                children: [
                  _detailRow('Partner Shop', booking.shopName),
                  const Divider(height: 20),
                  _detailRow('Location', booking.location),
                  const Divider(height: 20),
                  _detailRow('Start Date', formatDate(booking.startDate)),
                  const Divider(height: 20),
                  _detailRow('End Date', formatDate(booking.endDate)),
                  const Divider(height: 20),
                  _detailRow('Duration', '${booking.numberOfDays} day(s)'),
                  const Divider(height: 20),
                  _detailRow(
                    'Total Fare',
                    '₹${booking.totalAmount.toStringAsFixed(0)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (booking.status.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cancel Booking?'),
                        content: const Text(
                          'Are you sure you want to cancel this booking request?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Keep Booking'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Confirm Cancel'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true || !context.mounted) return;

                    bool result = await Provider.of<BookingProvider>(
                      context,
                      listen: false,
                    ).cancelBooking(booking.id);

                    if (!context.mounted) return;

                    if (result) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking request cancelled successfully'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Cancel Booking Request',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.maltMuted,
          ),
        ),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: TextStyle(
            fontSize: isHighlight ? 17 : 15,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isHighlight ? AppColors.malt : AppColors.malt,
          ),
        ),
      ],
    );
  }

  String formatDate(String date) {
    try {
      DateTime d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (e) {
      return date;
    }
  }
}