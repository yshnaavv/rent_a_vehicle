import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/owner_provider.dart';
import '../../theme/app_theme.dart';
import 'owner_home.dart';
import 'owner_login_screen.dart';

class OwnerPendingApprovalScreen extends StatefulWidget {
  final String status;

  const OwnerPendingApprovalScreen({super.key, this.status = 'pending'});

  @override
  State<OwnerPendingApprovalScreen> createState() =>
      _OwnerPendingApprovalScreenState();
}

class _OwnerPendingApprovalScreenState
    extends State<OwnerPendingApprovalScreen> {
  bool isChecking = false;

  Future<void> checkStatus() async {
    setState(() {
      isChecking = true;
    });

    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final status = await provider.checkApprovalStatus();

    setState(() {
      isChecking = false;
    });

    if (!mounted) return;

    if (status == 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Congratulations! Your partner account is approved.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerHome()),
      );
    } else if (status == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application has been rejected by administrator.'),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (status == 'suspended') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your account is currently suspended. Please contact support.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account is waiting for admin approval.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final data = provider.ownerData;
    final status = provider.currentApprovalStatus;

    final isRejected = status == 'rejected';
    final isSuspended = status == 'suspended';
    final isPending = !isRejected && !isSuspended;

    Color badgeColor = AppColors.warning;
    Color badgeBg = AppColors.warningLight;
    IconData iconData = Icons.hourglass_top_rounded;
    String title = 'Your account is waiting for admin approval';
    String message =
        'Thank you for registering your shop. An administrator is currently reviewing your shop documents and business credentials. You will gain full access to your fleet and dashboard once approved.';

    if (isRejected) {
      badgeColor = AppColors.error;
      badgeBg = AppColors.errorLight;
      iconData = Icons.cancel_outlined;
      title = 'Partner Application Rejected';
      message = 'Unfortunately, your vehicle partner application was not approved by the administrator. Please contact our support team if you believe this was an error.';
    } else if (isSuspended) {
      badgeColor = AppColors.error;
      badgeBg = AppColors.errorLight;
      iconData = Icons.block_rounded;
      title = 'Partner Account Suspended';
      message = 'Your partner account has been temporarily suspended by the administrator. Fleet bookings and vehicle listings are paused.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Status'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              await provider.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status Badge Icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: badgeColor, width: 2),
                    ),
                    child: Icon(iconData, size: 46, color: badgeColor),
                  ),

                  const SizedBox(height: 24),

                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.maltMuted,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Partner Shop Summary Card
                  if (data != null) ...[
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
                          const Text(
                            'Registered Partner Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.maltMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Divider(height: 16),
                          _detailItem(
                            Icons.storefront_rounded,
                            'Shop Name',
                            data['shopName'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _detailItem(
                            Icons.person_outline,
                            'Owner Name',
                            data['fullName'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _detailItem(
                            Icons.email_outlined,
                            'Email',
                            data['email'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _detailItem(
                            Icons.phone_outlined,
                            'Mobile',
                            data['mobile'] ?? '',
                          ),
                          if ((data['city'] ?? '').toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _detailItem(
                              Icons.location_on_outlined,
                              'Location',
                              '${data['city']}, ${data['state']}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Action Buttons
                  if (isPending) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isChecking ? null : checkStatus,
                        icon: isChecking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.malt,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        label: Text(
                          isChecking
                              ? 'Checking Status...'
                              : 'Check Approval Status',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await provider.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerLoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign Out / Back to Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.malt),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.maltMuted),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.malt,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
