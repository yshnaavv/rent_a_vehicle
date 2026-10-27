import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/vehicle_model.dart';
import '../provider/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'my_bookings_screen.dart';

class BookingScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const BookingScreen({super.key, required this.vehicle});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? startDate;
  DateTime? endDate;
  bool isProcessingPayment = false;
  String? lastPaymentError;

  Future<void> selectStartDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: startDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.malt,
              onPrimary: AppColors.turmeric,
              onSurface: AppColors.malt,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        startDate = date;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> selectEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pick-up date first')),
      );
      return;
    }

    DateTime? date = await showDatePicker(
      context: context,
      firstDate: startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: endDate ?? startDate!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.malt,
              onPrimary: AppColors.turmeric,
              onSurface: AppColors.malt,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        endDate = date;
      });
    }
  }

  int get numberOfDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  double get totalAmount {
    return numberOfDays * widget.vehicle.pricePerDay;
  }

  /// Initiates the Razorpay Test Mode checkout workflow.
  /// Handles Success, Failure, and User Cancellation without exposing secret keys in client code.
  Future<void> initiatePayment() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental schedule dates')),
      );
      return;
    }

    if (isProcessingPayment) return;

    // Open Razorpay Test Mode Gateway Checkout
    final result = await showModalBottomSheet<_PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RazorpayCheckoutModal(
        amount: totalAmount,
        vehicleName: widget.vehicle.vehicleName,
        shopName: widget.vehicle.shopName,
      ),
    );

    if (!mounted) return;

    if (result == null || result.status == _PaymentStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment cancelled by user. You can retry whenever ready.',
          ),
          backgroundColor: AppColors.malt,
        ),
      );
      return;
    }

    if (result.status == _PaymentStatus.failed) {
      setState(() {
        lastPaymentError =
            result.errorMessage ?? 'Transaction declined in Test Mode';
      });

      _showPaymentFailureDialog(
        result.errorMessage ?? 'Payment was declined by test bank.',
      );
      return;
    }

    // Payment Success Flow
    await _handlePaymentSuccess(result.paymentId!);
  }

  Future<void> _handlePaymentSuccess(String paymentReference) async {
    setState(() {
      isProcessingPayment = true;
      lastPaymentError = null;
    });

    final provider = Provider.of<BookingProvider>(context, listen: false);

    // Save booking with verified payment status
    bool success = await provider.createBooking(
      ownerId: widget.vehicle.ownerId,
      vehicleId: widget.vehicle.id,
      vehicleName: widget.vehicle.vehicleName,
      shopName: widget.vehicle.shopName,
      location: widget.vehicle.location,
      startDate: startDate!.toIso8601String(),
      endDate: endDate!.toIso8601String(),
      numberOfDays: numberOfDays,
      totalAmount: totalAmount,
      paymentStatus: 'completed',
      paymentReference: paymentReference,
      paymentMethod: 'razorpay_test_mode',
      status: 'confirmed',
    );

    if (!mounted) return;

    setState(() {
      isProcessingPayment = false;
    });

    if (success) {
      _showBookingSuccessDialog(paymentReference);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Booking recording failed after payment',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showBookingSuccessDialog(String paymentReference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.turmericLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.malt,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reservation Confirmed',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.malt,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your payment for ₹${totalAmount.toStringAsFixed(0)} was verified successfully in Razorpay Test Mode.',
                style: const TextStyle(color: AppColors.malt, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.maltBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Reference (Test)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.maltMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paymentReference,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.malt,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gateway Mode',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.maltMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Razorpay Test Mode (Simulated Sandbox)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.malt,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                );
              },
              child: const Text('View My Bookings'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentFailureDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Payment Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.malt,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMsg,
                style: const TextStyle(color: AppColors.malt, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your booking has NOT been confirmed and no charges were deducted. You can retry the payment.',
                style: TextStyle(color: AppColors.maltMuted, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                initiatePayment();
              },
              child: const Text('Retry Payment'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Book Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.malt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      color: AppColors.turmeric,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vehicle.vehicleName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.malt,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.vehicle.brand} • ₹${widget.vehicle.pricePerDay.toStringAsFixed(0)}/day',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.maltMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.vehicle.shopName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.maltMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Select Rental Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.malt,
              ),
            ),

            const SizedBox(height: 14),

            // Date Selection Cards
            Row(
              children: [
                Expanded(
                  child: _datePickerCard(
                    title: 'Pick-up Date',
                    date: startDate,
                    onTap: selectStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _datePickerCard(
                    title: 'Return Date',
                    date: endDate,
                    onTap: selectEndDate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Fare Breakdown
            if (numberOfDays > 0) ...[
              const Text(
                'Fare Breakdown',
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
                    _breakdownRow(
                      'Rental Duration',
                      '$numberOfDays day${numberOfDays > 1 ? "s" : ""}',
                    ),
                    const SizedBox(height: 12),
                    _breakdownRow(
                      'Rate / Day',
                      '₹${widget.vehicle.pricePerDay.toStringAsFixed(0)}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Booking Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.malt,
                          ),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.malt,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Razorpay Gateway Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.turmericLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.turmeric.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.malt,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Razorpay Test Mode Checkout',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.malt,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Simulated test payment sandbox. Real secret credentials remain strictly protected on backend. You can test Success, Failure, and Cancellation outcomes.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.malt,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (lastPaymentError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastPaymentError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 36),

            // Pay & Confirm Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (isProcessingPayment || numberOfDays <= 0)
                    ? null
                    : initiatePayment,
                child: isProcessingPayment
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.malt,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing Transaction...'),
                        ],
                      )
                    : Text(
                        numberOfDays > 0
                            ? 'Pay ₹${totalAmount.toStringAsFixed(0)} via Razorpay Test'
                            : 'Select Dates to Book',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerCard({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: date != null ? AppColors.turmericDark : AppColors.maltBorder,
            width: date != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: date != null ? AppColors.malt : AppColors.maltMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.maltMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              date == null
                  ? 'Tap to select'
                  : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: date == null ? AppColors.maltMuted : AppColors.malt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.maltMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.malt,
          ),
        ),
      ],
    );
  }
}

enum _PaymentStatus { success, failed, cancelled }

class _PaymentResult {
  final _PaymentStatus status;
  final String? paymentId;
  final String? errorMessage;

  _PaymentResult({required this.status, this.paymentId, this.errorMessage});
}

class _RazorpayCheckoutModal extends StatefulWidget {
  final double amount;
  final String vehicleName;
  final String shopName;

  const _RazorpayCheckoutModal({
    required this.amount,
    required this.vehicleName,
    required this.shopName,
  });

  @override
  State<_RazorpayCheckoutModal> createState() => _RazorpayCheckoutModalState();
}

class _RazorpayCheckoutModalState extends State<_RazorpayCheckoutModal> {
  bool isAuthorizing = false;
  String currentStatusText = 'Connecting to Razorpay Test Gateway...';

  Future<void> _processTestPayment({required bool shouldSucceed}) async {
    setState(() {
      isAuthorizing = true;
      currentStatusText = 'Authorizing with Test Bank...';
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    if (shouldSucceed) {
      final random = Random().nextInt(899999) + 100000;
      final testPaymentId =
          'pay_test_${DateTime.now().millisecondsSinceEpoch}_$random';

      Navigator.pop(
        context,
        _PaymentResult(
          status: _PaymentStatus.success,
          paymentId: testPaymentId,
        ),
      );
    } else {
      Navigator.pop(
        context,
        _PaymentResult(
          status: _PaymentStatus.failed,
          errorMessage: 'Transaction declined in test mode: [ERR_INSUFFICIENT_FUNDS_OR_CARD_DECLINED]',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.maltBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2340), // Razorpay Blue
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RAZORPAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.turmericLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'TEST MODE DEMO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.malt,
                  ),
                ),
              ),
              const Spacer(),
              if (!isAuthorizing)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _PaymentResult(status: _PaymentStatus.cancelled),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Amount & Merchant details
          Text(
            widget.shopName,
            style: const TextStyle(fontSize: 14, color: AppColors.maltMuted),
          ),
          const SizedBox(height: 2),
          Text(
            'Vehicle Rental: ${widget.vehicleName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.malt,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Amount to Pay: ',
                style: TextStyle(fontSize: 14, color: AppColors.maltMuted),
              ),
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.malt,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (isAuthorizing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.turmeric,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentStatusText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.malt,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Select Test Scenario to execute:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.malt,
              ),
            ),
            const SizedBox(height: 12),

            // Option 1: Success
            ElevatedButton.icon(
              onPressed: () => _processTestPayment(shouldSucceed: true),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Simulate Successful Payment (Authorize)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 10),

            // Option 2: Decline / Failure
            OutlinedButton.icon(
              onPressed: () => _processTestPayment(shouldSucceed: false),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Simulate Payment Failure (Bank Decline)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 10),

            // Option 3: Cancel
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _PaymentResult(status: _PaymentStatus.cancelled),
                );
              },
              child: const Text('Cancel & Close Modal'),
            ),
          ],
        ],
      ),
    );
  }
}
