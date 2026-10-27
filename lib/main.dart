import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';

// User providers
import 'user/provider/user_provider.dart';
import 'user/provider/vehicle_provider.dart';
import 'user/provider/booking_provider.dart';
import 'user/provider/user_complaint_provider.dart';

// Owner providers
import 'owner/provider/owner_provider.dart';
import 'owner/provider/owner_vehicle_provider.dart';
import 'owner/provider/owner_booking_provider.dart';

// Admin providers
import 'admin/provider/admin_provider.dart';
import 'admin/provider/admin_booking_provider.dart';
import 'admin/provider/admin_owner_provider.dart';
import 'admin/provider/admin_vehicle_provider.dart';
import 'admin/provider/admin_complaint_provider.dart';
import 'admin/provider/admin_review_provider.dart';

// Initial Screen
import 'screen/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // User Providers
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => UserComplaintProvider()),

        // Owner Providers
        ChangeNotifierProvider(create: (_) => OwnerProvider()),
        ChangeNotifierProvider(create: (_) => OwnerVehicleProvider()),
        ChangeNotifierProvider(create: (_) => OwnerBookingProvider()),

        // Admin Providers
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminBookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminOwnerProvider()),
        ChangeNotifierProvider(create: (_) => AdminVehicleProvider()),
        ChangeNotifierProvider(create: (_) => AdminComplaintProvider()),
        ChangeNotifierProvider(create: (_) => AdminReviewProvider()),
      ],
      child: const RentAVehicleApp(),
    ),
  );
}

class RentAVehicleApp extends StatelessWidget {
  const RentAVehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent A Vehicle',
      theme: AppTheme.themeData,
      home: const RoleSelectionScreen(),
    );
  }
}
