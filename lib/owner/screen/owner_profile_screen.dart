import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/owner_provider.dart';
import '../../theme/app_theme.dart';
import 'owner_login_screen.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final data = provider.ownerData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Partner Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.malt,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.turmeric, width: 3),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 42,
                      color: AppColors.turmeric,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data?['fullName'] ?? 'Partner',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data?['shopName'] ?? 'Vehicle Shop',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.turmericDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Partner details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.maltBorder),
              ),
              child: Column(
                children: [
                  _infoTile(
                    Icons.email_outlined,
                    'Email',
                    data?['email'] ?? 'Not set',
                  ),
                  const Divider(height: 1, indent: 56),
                  _infoTile(
                    Icons.phone_outlined,
                    'Mobile',
                    data?['mobile'] ?? 'Not set',
                  ),
                  const Divider(height: 1, indent: 56),
                  _infoTile(
                    Icons.business_outlined,
                    'Shop Name',
                    data?['shopName'] ?? 'Not set',
                  ),
                  const Divider(height: 1, indent: 56),
                  _infoTile(
                    Icons.location_on_outlined,
                    'Shop Address',
                    data?['shopAddress'] ?? 'Not set',
                  ),
                  const Divider(height: 1, indent: 56),
                  _infoTile(
                    Icons.map_outlined,
                    'City / State',
                    '${data?['city'] ?? ''}, ${data?['state'] ?? ''}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out?'),
                      content: const Text(
                        'Are you sure you want to sign out from Partner portal?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true || !context.mounted) return;

                  await provider.logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Sign Out from Partner Portal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.turmericLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.malt, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.maltMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.malt,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
