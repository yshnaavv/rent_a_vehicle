import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/admin_owner_provider.dart';
import '../../theme/app_theme.dart';

class ManageOwnersScreen extends StatefulWidget {
  const ManageOwnersScreen({super.key});

  @override
  State<ManageOwnersScreen> createState() => _ManageOwnersScreenState();
}

class _ManageOwnersScreenState extends State<ManageOwnersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<AdminOwnerProvider>(
        context,
        listen: false,
      ).getOwners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Partners'),
      ),
      body: Consumer<AdminOwnerProvider>(
        builder: (context, provider, child) {
          if (provider.owners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: AppColors.turmericLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Partner Accounts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Registered vehicle partners and shops will show up here.',
                    style: TextStyle(
                      color: AppColors.maltMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.owners.length,
            itemBuilder: (context, index) {
              final owner = provider.owners[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: AppColors.maltBorder.withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.malt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.turmeric,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              owner.shopName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.malt,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${owner.fullName} • ${owner.email}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.maltMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${owner.city}, ${owner.state} • Phone: ${owner.mobile}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.maltMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}