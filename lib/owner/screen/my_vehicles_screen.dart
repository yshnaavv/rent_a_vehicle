import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/owner_vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_helper.dart';
import 'add_vehicle_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<OwnerVehicleProvider>(context, listen: false).getMyVehicles();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.successLight;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Fleet Vehicles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Vehicle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OwnerVehicleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.turmeric),
            );
          }

          if (provider.vehicles.isEmpty) {
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
                      Icons.directions_car_outlined,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Vehicles in Fleet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add your first car or bike to start taking rentals.',
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddVehicleScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Vehicle Now'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.getMyVehicles,
            color: AppColors.turmeric,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = provider.vehicles[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.maltBorder.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 80,
                            height: 80,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      vehicle.vehicleName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.malt,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusBgColor(
                                        vehicle.approvalStatus,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      vehicle.approvalStatus.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _statusColor(
                                          vehicle.approvalStatus,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${vehicle.brand} ${vehicle.model} • ${vehicle.category}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.maltMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${vehicle.pricePerDay.toStringAsFixed(0)} / day',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.malt,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        vehicle.isAvailable
                                            ? 'Available'
                                            : 'Paused',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: vehicle.isAvailable
                                              ? AppColors.success
                                              : AppColors.maltMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Transform.scale(
                                        scale: 0.75,
                                        child: Switch(
                                          activeThumbColor: AppColors.turmeric,
                                          value: vehicle.isAvailable,
                                          onChanged: (val) {
                                            provider.changeAvailability(
                                              vehicle.id,
                                              val,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
