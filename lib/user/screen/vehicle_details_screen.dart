import 'package:flutter/material.dart';

import '../model/vehicle_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_helper.dart';
import 'booking_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  int activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final images = vehicle.images;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(vehicle.vehicleName)),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.malt.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Rate',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.maltMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${vehicle.pricePerDay.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vehicle.isAvailable
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(vehicle: vehicle),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vehicle.isAvailable
                          ? AppColors.turmeric
                          : Colors.grey.shade400,
                    ),
                    child: Text(
                      vehicle.isAvailable ? 'Book This Vehicle' : 'Unavailable',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Hero Image Gallery
            Stack(
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: images.isNotEmpty
                      ? ImageHelper.buildVehicleImage(
                          images: [images[activeImageIndex]],
                          width: double.infinity,
                          height: 260,
                          fit: BoxFit.cover,
                          fallbackIcon: vehicle.category == 'bike'
                              ? Icons.two_wheeler
                              : Icons.directions_car,
                        )
                      : Container(
                          color: AppColors.turmericLight,
                          child: Icon(
                            vehicle.category == 'bike'
                                ? Icons.two_wheeler
                                : Icons.directions_car,
                            size: 80,
                            color: AppColors.malt,
                          ),
                        ),
                ),

                // Availability badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.isAvailable
                          ? AppColors.success
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.isAvailable
                              ? 'AVAILABLE NOW'
                              : 'NOT AVAILABLE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Multiple image thumbnail selector if more than 1 image
            if (images.length > 1)
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, idx) {
                    final isSelected = activeImageIndex == idx;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          activeImageIndex = idx;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.turmeric
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ImageHelper.buildVehicleImage(
                            images: [images[idx]],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Vehicle Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.vehicleName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.malt,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vehicle.brand} • ${vehicle.model}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.maltMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.turmericLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.malt,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Specifications Grid
                  const Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _specCard(
                          icon: Icons.settings_rounded,
                          title: 'Transmission',
                          value: vehicle.transmission,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          icon: Icons.local_gas_station_rounded,
                          title: 'Fuel Type',
                          value: vehicle.fuelType,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _specCard(
                          icon: Icons.event_seat_rounded,
                          title: 'Capacity',
                          value: '${vehicle.seats} Seats',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _specCard(
                          icon: Icons.location_on_rounded,
                          title: 'Location',
                          value: vehicle.location,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Partner Shop Card
                  if (vehicle.shopName.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.maltBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.malt,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.turmeric,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Partner Shop',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.maltMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  vehicle.shopName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.malt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  const Text(
                    'About this Vehicle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.maltBorder),
                    ),
                    child: Text(
                      vehicle.description.trim().isEmpty
                          ? 'Well-maintained, fully serviced and ready for your rental journey. Sanitized and safety inspected.'
                          : vehicle.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.malt,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.maltBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.malt, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.maltMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.malt,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
