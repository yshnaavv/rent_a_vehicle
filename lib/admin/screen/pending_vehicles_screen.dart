import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/admin_vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_helper.dart';

class PendingVehiclesScreen extends StatefulWidget {
  const PendingVehiclesScreen({super.key});

  @override
  State<PendingVehiclesScreen> createState() => _PendingVehiclesScreenState();
}

class _PendingVehiclesScreenState extends State<PendingVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<AdminVehicleProvider>(
        context,
        listen: false,
      ).getAllVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: Consumer<AdminVehicleProvider>(
        builder: (context, provider, child) {
          final pendingVehicles = provider.vehicles
              .where((v) => v.approvalStatus.toLowerCase() == 'pending')
              .toList();

          if (pendingVehicles.isEmpty) {
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
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'All Clear!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'No vehicles currently pending administrative approval.',
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pendingVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = pendingVehicles[index];

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: ImageHelper.buildVehicleImage(
                                images: vehicle.images,
                                fit: BoxFit.cover,
                                fallbackIcon: vehicle.category == 'bike'
                                    ? Icons.two_wheeler
                                    : Icons.directions_car,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.vehicleName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.malt,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${vehicle.brand} ${vehicle.model} • ${vehicle.category.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.maltMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Partner: ${vehicle.shopName} • ${vehicle.location}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.maltMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PENDING',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rental Rate: ₹${vehicle.pricePerDay.toStringAsFixed(0)} / day',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.malt,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await provider.approveVehicle(vehicle.id);
                              },
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Approve Vehicle'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              onPressed: () async {
                                await provider.rejectVehicle(vehicle.id);
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
