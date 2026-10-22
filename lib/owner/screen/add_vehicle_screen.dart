import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';

import '../provider/owner_vehicle_provider.dart';
import '../provider/owner_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_helper.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final vehicleNameController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final seatsController = TextEditingController(text: '4');
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  String category = 'car';
  String transmission = 'Manual';
  String fuelType = 'Petrol';
  List<String> base64Images = [];
  bool loading = false;

  @override
  void dispose() {
    vehicleNameController.dispose();
    brandController.dispose();
    modelController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    priceController.dispose();
    seatsController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    Uint8List originalBytes = await image.readAsBytes();

    Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      originalBytes,
      minWidth: 800,
      minHeight: 600,
      quality: 60,
    );

    String base64Image = base64Encode(compressedBytes);

    setState(() {
      base64Images.add(base64Image);
    });
  }

  Future<void> saveVehicle() async {
    if (vehicleNameController.text.trim().isEmpty ||
        brandController.text.trim().isEmpty ||
        modelController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required vehicle fields'),
        ),
      );
      return;
    }

    final ownerProvider = Provider.of<OwnerProvider>(
      context,
      listen: false,
    );

    final vehicleProvider = Provider.of<OwnerVehicleProvider>(
      context,
      listen: false,
    );

    setState(() {
      loading = true;
    });

    bool success = await vehicleProvider.addVehicle(
      vehicleName: vehicleNameController.text.trim(),
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      category: category,
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      latitude: double.tryParse(latitudeController.text.trim()) ?? 0,
      longitude: double.tryParse(longitudeController.text.trim()) ?? 0,
      pricePerDay: double.tryParse(priceController.text.trim()) ?? 0,
      transmission: transmission,
      fuelType: fuelType,
      seats: int.tryParse(seatsController.text.trim()) ?? 0,
      images: base64Images,
      shopName: ownerProvider.ownerData?['shopName'] ?? '',
    );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle submitted successfully. Waiting for admin approval.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vehicleProvider.errorMessage ?? 'Failed to add vehicle'),
        ),
      );
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.turmericLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.malt, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.malt,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Vehicle to Fleet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Details Section
            _sectionTitle('Vehicle Identification', Icons.directions_car_rounded),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: vehicleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Title / Name *',
                      hintText: 'e.g. BMW M4 Competition',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand *',
                            hintText: 'e.g. BMW',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model *',
                            hintText: 'e.g. M4',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'car', child: Text('Car')),
                      DropdownMenuItem(value: 'bike', child: Text('Bike')),
                      DropdownMenuItem(value: 'modified', child: Text('Modified Vehicle')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          category = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Highlights',
                      hintText: 'Describe vehicle condition, features, special equipment...',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Specifications Section
            _sectionTitle('Specifications', Icons.tune_rounded),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: transmission,
                          decoration: const InputDecoration(
                            labelText: 'Transmission *',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                            DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                transmission = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: fuelType,
                          decoration: const InputDecoration(
                            labelText: 'Fuel Type *',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                            DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                            DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                            DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                fuelType = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: seatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Seating Capacity *',
                      hintText: 'Number of passenger seats',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Location & Pricing Section
            _sectionTitle('Rates & Location', Icons.attach_money_rounded),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily Rental Rate (₹) *',
                      hintText: 'e.g. 2500',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Pick-up Location / City *',
                      hintText: 'e.g. Downtown Metro Hub',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            hintText: 'Optional',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            hintText: 'Optional',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Images Section
            _sectionTitle('Vehicle Photos', Icons.photo_camera_rounded),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Select Photo from Gallery'),
                  ),
                  const SizedBox(height: 14),
                  if (base64Images.isNotEmpty) ...[
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: base64Images.length,
                        itemBuilder: (context, idx) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.maltBorder),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: ImageHelper.buildVehicleImage(
                                    images: [base64Images[idx]],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 14,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      base64Images.removeAt(idx);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    '${base64Images.length} photo(s) selected',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.maltMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : saveVehicle,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.malt,
                        ),
                      )
                    : const Text(
                        'Submit Vehicle for Approval',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}