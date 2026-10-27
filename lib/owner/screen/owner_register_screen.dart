import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../provider/owner_provider.dart';
import '../../theme/app_theme.dart';
import 'owner_pending_approval_screen.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  final shopNameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final shopPhoneController = TextEditingController();

  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  bool obscurePassword = true;
  bool isDetectingLocation = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();

    shopNameController.dispose();
    shopAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    shopPhoneController.dispose();

    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> autoDetectLocation() async {
    setState(() {
      isDetectingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location service is off. You can enter your shop address manually without GPS.',
            ),
            backgroundColor: AppColors.malt,
          ),
        );
        setState(() => isDetectingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission skipped. You can enter your address and coordinates manually.',
              ),
              backgroundColor: AppColors.malt,
            ),
          );
          setState(() => isDetectingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission not enabled. You can continue with manual shop address.',
            ),
            backgroundColor: AppColors.malt,
          ),
        );
        setState(() => isDetectingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);

      // Reverse geocoding to auto-fill address fields
      try {
        List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          if (cityController.text.isEmpty &&
              (place.locality ?? '').isNotEmpty) {
            cityController.text = place.locality!;
          }
          if (stateController.text.isEmpty &&
              (place.administrativeArea ?? '').isNotEmpty) {
            stateController.text = place.administrativeArea!;
          }
          if (pincodeController.text.isEmpty &&
              (place.postalCode ?? '').isNotEmpty) {
            pincodeController.text = place.postalCode!;
          }
          if (shopAddressController.text.isEmpty) {
            final street = place.street ?? '';
            final subLoc = place.subLocality ?? '';
            shopAddressController.text = [
              street,
              subLoc,
            ].where((s) => s.isNotEmpty).join(', ');
          }
        }
      } catch (_) {
        // Geocoding optional fallback
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS coordinates and location detected successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to detect location: $e')));
    } finally {
      if (mounted) {
        setState(() => isDetectingLocation = false);
      }
    }
  }

  Future<void> registerOwner() async {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        shopNameController.text.trim().isEmpty ||
        shopAddressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required partner fields'),
        ),
      );
      return;
    }

    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
        ),
      );
      return;
    }

    bool success = await Provider.of<OwnerProvider>(context, listen: false)
        .registerOwner(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobileController.text.trim(),
          password: passwordController.text.trim(),
          shopName: shopNameController.text.trim(),
          shopAddress: shopAddressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          shopPhone: shopPhoneController.text.trim(),
          latitude: double.tryParse(latitudeController.text.trim()) ?? 0,
          longitude: double.tryParse(longitudeController.text.trim()) ?? 0,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account is waiting for admin approval.'),
        ),
      );

      // Navigate to Pending Approval Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OwnerPendingApprovalScreen(status: 'pending'),
        ),
      );
    } else {
      final provider = Provider.of<OwnerProvider>(context, listen: false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Partner registration failed'),
        ),
      );
    }
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
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
      appBar: AppBar(title: const Text('Partner Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.turmericLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.turmeric),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.malt),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Applications require administrative review before fleet dashboard access is activated.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.malt.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Details Card
            _sectionHeader('Personal Information', Icons.person_rounded),
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
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number *',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.maltMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Shop Details Card
            _sectionHeader('Shop / Business Details', Icons.storefront_rounded),
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
                    controller: shopNameController,
                    decoration: const InputDecoration(
                      labelText: 'Shop / Company Name *',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: shopAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address *',
                      prefixIcon: Icon(Icons.home_work_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: 'City *',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stateController,
                          decoration: const InputDecoration(
                            labelText: 'State *',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pincodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Pincode',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: shopPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Shop Phone',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Coordinates Card with GPS Auto-detection
            _sectionHeader(
              'Shop Location & Coordinates (Optional)',
              Icons.location_on_rounded,
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPS auto-detection is optional. If you cannot allow location permission on your phone, you can enter your shop address manually above and leave coordinates as 0 or type them manually.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.maltMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: isDetectingLocation
                          ? null
                          : autoDetectLocation,
                      icon: isDetectingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.malt,
                              ),
                            )
                          : const Icon(Icons.my_location_rounded, size: 20),
                      label: Text(
                        isDetectingLocation
                            ? 'Detecting GPS Location...'
                            : 'Auto-Detect Shop Location via GPS',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            hintText: 'e.g. 12.9716',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            hintText: 'e.g. 77.5946',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Consumer<OwnerProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : registerOwner,
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
                            'Submit Application for Approval',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
