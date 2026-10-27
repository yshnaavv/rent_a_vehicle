import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/vehicle_provider.dart';
import '../model/vehicle_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_helper.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final String category;
  final String title;

  const VehicleListScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  List<VehicleModel> vehicles = [];
  bool loading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadVehicles() async {
    final provider = Provider.of<VehicleProvider>(context, listen: false);

    List<VehicleModel> result = await provider.getVehiclesByCategory(
      widget.category,
    );

    if (!mounted) return;

    setState(() {
      vehicles = result;
      loading = false;
    });
  }

  List<VehicleModel> get filteredVehicles {
    if (searchQuery.trim().isEmpty) return vehicles;
    final q = searchQuery.toLowerCase();
    return vehicles.where((v) {
      return v.vehicleName.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q) ||
          v.location.toLowerCase().contains(q) ||
          v.shopName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by model, brand, location...',
                prefixIcon: const Icon(Icons.search, color: AppColors.malt),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.maltMuted,
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Vehicle List
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.turmeric),
                  )
                : filteredVehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.turmericLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_outlined,
                            size: 54,
                            color: AppColors.malt,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No vehicles available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.malt,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Try searching with different keywords'
                              : 'Check back later for new additions',
                          style: const TextStyle(
                            color: AppColors.maltMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadVehicles,
                    color: AppColors.turmeric,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = filteredVehicles[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: AppColors.maltBorder.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VehicleDetailsScreen(vehicle: vehicle),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Vehicle Image with Safe Decoder
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                  child: Stack(
                                    children: [
                                      ImageHelper.buildVehicleImage(
                                        images: vehicle.images,
                                        height: 190,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        fallbackIcon: widget.category == 'bike'
                                            ? Icons.two_wheeler_rounded
                                            : Icons.directions_car_rounded,
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.malt.withValues(
                                              alpha: 0.85,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '₹${vehicle.pricePerDay.toStringAsFixed(0)} / day',
                                            style: const TextStyle(
                                              color: AppColors.turmeric,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (vehicle.shopName.isNotEmpty)
                                        Positioned(
                                          bottom: 12,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.storefront_rounded,
                                                  size: 13,
                                                  color: AppColors.malt,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  vehicle.shopName,
                                                  style: const TextStyle(
                                                    color: AppColors.malt,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Vehicle Info
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              vehicle.vehicleName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
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
                                              color: AppColors.turmericLight,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              vehicle.brand.toUpperCase(),
                                              style: const TextStyle(
                                                color: AppColors.malt,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 15,
                                            color: AppColors.maltMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              vehicle.location,
                                              style: const TextStyle(
                                                color: AppColors.maltMuted,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Specs badges
                                      Row(
                                        children: [
                                          _specPill(
                                            Icons.settings_outlined,
                                            vehicle.transmission,
                                          ),
                                          const SizedBox(width: 8),
                                          _specPill(
                                            Icons.local_gas_station_outlined,
                                            vehicle.fuelType,
                                          ),
                                          const SizedBox(width: 8),
                                          _specPill(
                                            Icons.event_seat_outlined,
                                            '${vehicle.seats} seats',
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _specPill(IconData icon, String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.maltBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.malt),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.malt,
            ),
          ),
        ],
      ),
    );
  }
}
