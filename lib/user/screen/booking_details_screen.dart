import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/booking_model.dart';
import '../provider/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'user_complaint_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late BookingModel currentBooking;
  bool isRetryingPayment = false;

  @override
  void initState() {
    super.initState();
    currentBooking = widget.booking;
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

  Color _paymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Colors.green.shade700;
      case 'failed':
        return Colors.red.shade700;
      default:
        return Colors.amber.shade900;
    }
  }

  Color _paymentBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Colors.green.shade50;
      case 'failed':
        return Colors.red.shade50;
      default:
        return Colors.amber.shade50;
    }
  }

  Future<void> _retryPayment() async {
    setState(() => isRetryingPayment = true);

    final random = Random().nextInt(899999) + 100000;
    final testPaymentId =
        'pay_test_${DateTime.now().millisecondsSinceEpoch}_$random';

    final provider = Provider.of<BookingProvider>(context, listen: false);
    final success = await provider.updatePaymentStatus(
      bookingId: currentBooking.id,
      paymentStatus: 'completed',
      paymentReference: testPaymentId,
      paymentMethod: 'razorpay_test_mode',
      bookingStatus: 'confirmed',
    );

    if (!mounted) return;
    setState(() => isRetryingPayment = false);

    if (success) {
      setState(() {
        currentBooking = BookingModel(
          id: currentBooking.id,
          userId: currentBooking.userId,
          ownerId: currentBooking.ownerId,
          vehicleId: currentBooking.vehicleId,
          vehicleName: currentBooking.vehicleName,
          shopName: currentBooking.shopName,
          startDate: currentBooking.startDate,
          endDate: currentBooking.endDate,
          numberOfDays: currentBooking.numberOfDays,
          totalAmount: currentBooking.totalAmount,
          status: 'confirmed',
          location: currentBooking.location,
          paymentStatus: 'completed',
          paymentReference: testPaymentId,
          paymentMethod: 'razorpay_test_mode',
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment completed successfully via Razorpay Test Mode.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Payment update failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Details')),
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
                    currentBooking.vehicleName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBgColor(currentBooking.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'BOOKING: ${currentBooking.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(currentBooking.status),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _paymentBgColor(currentBooking.paymentStatus),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PAYMENT: ${currentBooking.paymentStatus.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _paymentColor(currentBooking.paymentStatus),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
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
                  _detailRow('Partner Shop', currentBooking.shopName),
                  const Divider(height: 20),
                  _detailRow('Location', currentBooking.location),
                  const Divider(height: 20),
                  _detailRow(
                    'Start Date',
                    formatDate(currentBooking.startDate),
                  ),
                  const Divider(height: 20),
                  _detailRow('End Date', formatDate(currentBooking.endDate)),
                  const Divider(height: 20),
                  _detailRow(
                    'Duration',
                    '${currentBooking.numberOfDays} day(s)',
                  ),
                  const Divider(height: 20),
                  _detailRow(
                    'Total Fare',
                    '₹${currentBooking.totalAmount.toStringAsFixed(0)}',
                    isHighlight: true,
                  ),
                  const Divider(height: 20),
                  _detailRow(
                    'Payment Status',
                    currentBooking.paymentStatus.toUpperCase(),
                  ),
                  if (currentBooking.paymentReference.isNotEmpty) ...[
                    const Divider(height: 20),
                    _detailRow(
                      'Payment Ref (Test)',
                      currentBooking.paymentReference,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Retry Payment button if not completed
            if (currentBooking.paymentStatus.toLowerCase() != 'completed' &&
                currentBooking.status.toLowerCase() != 'cancelled') ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isRetryingPayment ? null : _retryPayment,
                  icon: const Icon(Icons.payment_rounded),
                  label: isRetryingPayment
                      ? const Text('Processing Payment...')
                      : const Text('Complete Payment via Razorpay Test'),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Report Issue / Complaint Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Report an Issue / Submit Complaint'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserComplaintScreen(
                        preSelectedBookingId: currentBooking.id,
                        preSelectedVehicleId: currentBooking.vehicleId,
                        preSelectedOwnerId: currentBooking.ownerId,
                        preSelectedSubject:
                            'Issue with booking for ${currentBooking.vehicleName}',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            if (currentBooking.status.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50,
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
                    ).cancelBooking(currentBooking.id);

                    if (!context.mounted) return;

                    if (result) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Booking request cancelled successfully',
                          ),
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
          style: const TextStyle(fontSize: 14, color: AppColors.maltMuted),
        ),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: TextStyle(
            fontSize: isHighlight ? 17 : 14,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: AppColors.malt,
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
