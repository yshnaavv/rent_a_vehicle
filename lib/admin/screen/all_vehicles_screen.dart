import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/admin_vehicle_model.dart';
import '../provider/admin_vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_helper.dart';

class AllVehiclesScreen extends StatefulWidget {
  const AllVehiclesScreen({super.key});

  @override
  State<AllVehiclesScreen> createState() => _AllVehiclesScreenState();
}

class _AllVehiclesScreenState extends State<AllVehiclesScreen> {
  final TextEditingController searchController = TextEditingController();
  late Future<List<AdminVehicleModel>> vehiclesFuture;
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    vehiclesFuture = context.read<AdminVehicleProvider>().getVehicles();
  }

  void refreshVehicles() {
    setState(() {
      vehiclesFuture = context.read<AdminVehicleProvider>().getVehicles();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> performAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(successMessage)));
      refreshVehicles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> confirmDelete(AdminVehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vehicle?'),
          content: Text(
            'Are you sure you want to delete ${vehicle.vehicleName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      performAction(
        () => context.read<AdminVehicleProvider>().deleteVehicle(vehicle.id),
        'Vehicle deleted successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Fleet Vehicles'),
        actions: [
          IconButton(
            onPressed: refreshVehicles,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filters Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by model, brand, or shop...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.malt,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.maltMuted,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(value: 'car', child: Text('Cars')),
                      DropdownMenuItem(value: 'bike', child: Text('Bikes')),
                      DropdownMenuItem(
                        value: 'modified',
                        child: Text('Modified'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Vehicle list
            Expanded(
              child: FutureBuilder<List<AdminVehicleModel>>(
                future: vehiclesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.turmeric,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load vehicles: ${snapshot.error}'),
                    );
                  }

                  final allVehicles = snapshot.data ?? [];
                  final query = searchController.text.trim().toLowerCase();

                  final vehicles = allVehicles.where((vehicle) {
                    final matchesCategory =
                        selectedCategory == 'all' ||
                        vehicle.category.toLowerCase() == selectedCategory;
                    final matchesSearch =
                        vehicle.vehicleName.toLowerCase().contains(query) ||
                        vehicle.brand.toLowerCase().contains(query) ||
                        vehicle.shopName.toLowerCase().contains(query);

                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (vehicles.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching vehicles found.',
                        style: TextStyle(
                          color: AppColors.maltMuted,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];

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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 64,
                                      height: 64,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle.vehicleName,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.malt,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${vehicle.brand} • ${vehicle.category} • Shop: ${vehicle.shopName}',
                                          style: const TextStyle(
                                            color: AppColors.maltMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${vehicle.pricePerDay.toStringAsFixed(0)}/day • Location: ${vehicle.location}',
                                          style: const TextStyle(
                                            color: AppColors.malt,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
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
                                      color: vehicle.isAvailable
                                          ? AppColors.successLight
                                          : AppColors.errorLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      vehicle.isAvailable
                                          ? 'AVAILABLE'
                                          : 'UNAVAILABLE',
                                      style: TextStyle(
                                        color: vehicle.isAvailable
                                            ? AppColors.success
                                            : AppColors.error,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Text(
                                    'Available for Booking:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.maltMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      activeThumbColor: AppColors.turmeric,
                                      value: vehicle.isAvailable,
                                      onChanged: (val) {
                                        performAction(
                                          () => context
                                              .read<AdminVehicleProvider>()
                                              .changeAvailability(
                                                vehicle.id,
                                                val,
                                              ),
                                          'Availability updated',
                                        );
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.error,
                                    ),
                                    tooltip: 'Delete vehicle',
                                    onPressed: () => confirmDelete(vehicle),
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
            ),
          ],
        ),
      ),
    );
  }
}
