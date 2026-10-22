import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final data = provider.userData;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('My Profile'),
          ),
          body: data == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.turmeric),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar Card
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
                                Icons.person_rounded,
                                size: 44,
                                color: AppColors.turmeric,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              data['name'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.malt,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['email'] ?? '',
                              style: const TextStyle(
                                color: AppColors.maltMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Information Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.maltBorder),
                        ),
                        child: Column(
                          children: [
                            _profileTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Full Name',
                              value: data['name'] ?? 'Not set',
                            ),
                            const Divider(height: 1, indent: 56),
                            _profileTile(
                              icon: Icons.email_outlined,
                              title: 'Email Address',
                              value: data['email'] ?? 'Not set',
                            ),
                            const Divider(height: 1, indent: 56),
                            _profileTile(
                              icon: Icons.phone_outlined,
                              title: 'Phone Number',
                              value: data['phone'] ?? 'Not set',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: const Text(
                            'Edit Profile Information',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Log Out?'),
                                content: const Text('Are you sure you want to sign out?'),
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
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
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