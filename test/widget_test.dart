import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_a_vehicle/admin/model/admin_booking_model.dart';
import 'package:rent_a_vehicle/admin/model/admin_vehicle_model.dart';
import 'package:rent_a_vehicle/admin/model/complaint_model.dart';
import 'package:rent_a_vehicle/owner/model/vehicle_model.dart';
import 'package:rent_a_vehicle/screen/role_selection_screen.dart';
import 'package:rent_a_vehicle/user/model/booking_model.dart';
import 'package:rent_a_vehicle/user/model/vehicle_model.dart' as user_v;

void main() {
  group('BookingModel & Payment Tests', () {
    test('BookingModel correctly parses payment fields and defaults', () {
      final map = {
        'userId': 'user123',
        'ownerId': 'owner456',
        'vehicleId': 'veh789',
        'vehicleName': 'Harley Davidson',
        'shopName': 'Heritage Fleet',
        'startDate': '2026-11-01',
        'endDate': '2026-11-03',
        'numberOfDays': 2,
        'totalAmount': 5000.0,
        'status': 'confirmed',
        'location': 'Mumbai',
        'paymentStatus': 'completed',
        'paymentReference': 'pay_test_99887766',
        'paymentMethod': 'razorpay_test_mode',
      };

      final booking = BookingModel.fromMap(map, 'doc_abc');

      expect(booking.id, 'doc_abc');
      expect(booking.totalAmount, 5000.0);
      expect(booking.status, 'confirmed');
      expect(booking.paymentStatus, 'completed');
      expect(booking.paymentReference, 'pay_test_99887766');
      expect(booking.paymentMethod, 'razorpay_test_mode');
    });

    test('AdminBookingModel correctly parses payment status and defaults', () {
      final map = {
        'userId': 'user123',
        'ownerId': 'owner456',
        'vehicleId': 'veh789',
        'vehicleName': 'BMW M3',
        'shopName': 'Speed Rentals',
        'startDate': '2026-11-01',
        'endDate': '2026-11-02',
        'numberOfDays': 1,
        'totalAmount': 15000.0,
        'status': 'confirmed',
        'paymentStatus': 'completed',
        'paymentReference': 'pay_test_123456',
        'paymentMethod': 'razorpay_test_mode',
      };

      final adminBooking = AdminBookingModel.fromMap(map, 'admin_doc_1');

      expect(adminBooking.id, 'admin_doc_1');
      expect(adminBooking.paymentStatus, 'completed');
      expect(adminBooking.paymentReference, 'pay_test_123456');
    });
  });

  group('ComplaintModel Tests', () {
    test('ComplaintModel parses user complaints and timestamps', () {
      final map = {
        'userId': 'usr_99',
        'ownerId': 'own_44',
        'bookingId': 'bk_11',
        'vehicleId': 'vh_22',
        'subject': 'Cleanliness issue',
        'description': 'The car interior was not cleaned prior to delivery.',
        'submittedBy': 'user',
        'status': 'pending',
        'adminReply': '',
        'createdAt': '2026-10-25T18:00:00Z',
      };

      final complaint = ComplaintModel.fromMap(map, 'cmp_777');

      expect(complaint.id, 'cmp_777');
      expect(complaint.userId, 'usr_99');
      expect(complaint.bookingId, 'bk_11');
      expect(complaint.submittedBy, 'user');
      expect(complaint.status, 'pending');
      expect(complaint.adminReply, '');
      expect(complaint.createdAt, '2026-10-25T18:00:00Z');
    });
  });

  group('RoleSelectionScreen Responsive Platform Rendering', () {
    testWidgets('RoleSelectionScreen renders User and Partner on phone/mobile platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(home: RoleSelectionScreen()),
      );

      expect(find.text('Rent A Vehicle'), findsOneWidget);
      // On phone: Shows User and Partner
      expect(find.text('User Portal'), findsOneWidget);
      expect(find.text('Vehicle Partner'), findsOneWidget);
      // Administrator is strictly hidden on phone
      expect(find.text('Administrator'), findsNothing);

      debugDefaultTargetPlatformOverride = null;
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('RoleSelectionScreen renders Partner and Admin on desktop/computer platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(home: RoleSelectionScreen()),
      );

      expect(find.text('Rent A Vehicle'), findsOneWidget);
      // On computer: Shows Partner and Admin
      expect(find.text('Vehicle Partner'), findsOneWidget);
      expect(find.text('Administrator'), findsOneWidget);
      // User Portal is strictly hidden on desktop/computer
      expect(find.text('User Portal'), findsNothing);

      debugDefaultTargetPlatformOverride = null;
      addTearDown(tester.view.resetPhysicalSize);
    });
  });

  group('Vehicle Location & Direct Approval Tests', () {
    test(
      'OwnerVehicleModel parses city, GPS coordinates and approved status',
      () {
        final map = {
          'ownerId': 'owner_123',
          'vehicleName': 'Toyota Fortuner',
          'brand': 'Toyota',
          'model': 'Fortuner 4x4',
          'category': 'car',
          'description': 'Luxury SUV in pristine condition',
          'location': 'Andheri East Metro',
          'city': 'Mumbai',
          'latitude': 19.1136,
          'longitude': 72.8697,
          'pricePerDay': 4500.0,
          'transmission': 'Automatic',
          'fuelType': 'Diesel',
          'seats': 7,
          'images': <String>[],
          'approvalStatus': 'approved',
          'isAvailable': true,
          'shopName': 'Prime Auto Rentals',
        };

        final vehicle = OwnerVehicleModel.fromMap(map, 'veh_doc_99');
        expect(vehicle.id, 'veh_doc_99');
        expect(vehicle.city, 'Mumbai');
        expect(vehicle.location, 'Andheri East Metro');
        expect(vehicle.latitude, 19.1136);
        expect(vehicle.longitude, 72.8697);
        expect(vehicle.approvalStatus, 'approved');
        expect(vehicle.isAvailable, true);
      },
    );

    test('User VehicleModel parses city and coordinates', () {
      final map = {
        'ownerId': 'owner_123',
        'vehicleName': 'Royal Enfield Hunter 350',
        'brand': 'Royal Enfield',
        'model': 'Hunter',
        'category': 'bike',
        'description': 'City cruiser',
        'location': 'Koramangala 5th Block',
        'city': 'Bangalore',
        'latitude': 12.9352,
        'longitude': 77.6245,
        'pricePerDay': 900.0,
        'transmission': 'Manual',
        'fuelType': 'Petrol',
        'seats': 2,
        'images': <String>[],
        'approvalStatus': 'approved',
        'isAvailable': true,
        'shopName': 'City Bikes',
      };

      final vehicle = user_v.VehicleModel.fromMap(map, 'bike_doc_1');
      expect(vehicle.id, 'bike_doc_1');
      expect(vehicle.city, 'Bangalore');
      expect(vehicle.latitude, 12.9352);
      expect(vehicle.longitude, 77.6245);
      expect(vehicle.approvalStatus, 'approved');
    });

    test('AdminVehicleModel parses city and location', () {
      final map = {
        'ownerId': 'owner_123',
        'vehicleName': 'Honda City',
        'brand': 'Honda',
        'model': 'City ZX',
        'category': 'car',
        'location': 'Connaught Place',
        'city': 'New Delhi',
        'pricePerDay': 2200.0,
        'shopName': 'Capital Wheels',
        'approvalStatus': 'approved',
        'isAvailable': true,
      };

      final vehicle = AdminVehicleModel.fromMap(map, 'admin_veh_1');
      expect(vehicle.id, 'admin_veh_1');
      expect(vehicle.city, 'New Delhi');
      expect(vehicle.location, 'Connaught Place');
      expect(vehicle.approvalStatus, 'approved');
    });
  });
}
