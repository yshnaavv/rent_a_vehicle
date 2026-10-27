import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';

import '../admin/screen/admin_login_screen.dart';
import '../owner/screen/owner_login_screen.dart';
import '../user/screen/login_screen.dart';
import '../theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  /// Evaluates whether the application is running in a phone environment
  /// (Native mobile app or mobile web viewport) vs a computer/desktop environment.
  bool _isPhoneEnvironment(BuildContext context) {
    if (!kIsWeb) {
      // Native mobile builds: Android or iOS apps
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        return true;
      }
      // Native desktop OS builds: Windows, macOS, Linux
      return false;
    }

    // Flutter Web build running on computer vs mobile browser
    final width = MediaQuery.of(context).size.width;
    final isMobileOS =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (isMobileOS || width < 650) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = _isPhoneEnvironment(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium Brand Emblem
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.malt,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.malt.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_car_filled,
                        size: 46,
                        color: AppColors.turmeric,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Brand Title
                  const Text(
                    'Rent A Vehicle',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Tagline / Subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.turmericLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPhone
                          ? 'MOBILE MOBILITY PORTAL'
                          : 'DESKTOP COMMAND PORTAL',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.malt,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    isPhone
                        ? 'Select User or Partner portal to continue'
                        : 'Select Partner or Administrator portal to continue',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.maltMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // PHONE: Show User Portal & Vehicle Partner
                  if (isPhone) ...[
                    _roleCard(
                      context,
                      title: 'User Portal',
                      subtitle: 'Browse, book & drive premium vehicles',
                      icon: Icons.person_rounded,
                      badgeText: 'Explore',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _roleCard(
                      context,
                      title: 'Vehicle Partner',
                      subtitle: 'Manage shop, vehicles & fleet bookings',
                      icon: Icons.store_mall_directory_rounded,
                      badgeText: 'Partner',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ]
                  // COMPUTER / WEB BROWSER: Show Vehicle Partner & Admin
                  else ...[
                    _roleCard(
                      context,
                      title: 'Vehicle Partner',
                      subtitle: 'Manage shop, vehicles & fleet bookings',
                      icon: Icons.store_mall_directory_rounded,
                      badgeText: 'Partner',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerLoginScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _roleCard(
                      context,
                      title: 'Administrator',
                      subtitle:
                          'Platform analytics, fleet approvals & controls',
                      icon: Icons.admin_panel_settings_rounded,
                      badgeText: 'Control',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  Text(
                    isPhone
                        ? 'Secure & Reliable Mobile Fleet Rental'
                        : 'Administrative & Partner Management Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.maltMuted.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
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

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.maltBorder.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.malt.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          splashColor: AppColors.turmeric.withValues(alpha: 0.2),
          highlightColor: AppColors.turmericLight.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.malt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.turmeric, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.malt,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.turmericLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.malt,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.maltMuted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.malt,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
