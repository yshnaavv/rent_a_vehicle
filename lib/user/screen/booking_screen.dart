import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/vehicle_model.dart';
import '../provider/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'my_bookings_screen.dart';

class BookingScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const BookingScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? startDate;
  DateTime? endDate;

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

  Future<void> bookVehicle() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental schedule dates')),
      );
      return;
    }

    final provider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

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
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                const Text(
                  'Booking Confirmed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.malt,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your reservation for ${widget.vehicle.vehicleName} for $numberOfDays day(s) has been placed successfully.',
              style: const TextStyle(color: AppColors.malt),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyBookingsScreen(),
                    ),
                  );
                },
                child: const Text('View My Bookings'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Booking failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Vehicle'),
      ),
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
                          'Total Estimated Fare',
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
            ],

            const SizedBox(height: 36),

            // Confirm Button
            Consumer<BookingProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : bookVehicle,
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.malt,
                            ),
                          )
                        : const Text(
                            'Confirm & Create Reservation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
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
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.maltMuted,
          ),
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