import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/admin_owner_model.dart';
import '../provider/admin_owner_provider.dart';
import '../../theme/app_theme.dart';

class ManageOwnersScreen extends StatefulWidget {
  const ManageOwnersScreen({super.key});

  @override
  State<ManageOwnersScreen> createState() => _ManageOwnersScreenState();
}

class _ManageOwnersScreenState extends State<ManageOwnersScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'suspended'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<AdminOwnerProvider>(context, listen: false).getOwners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openMapDirections(double lat, double lng) async {
    if (lat == 0 && lng == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No GPS coordinates saved for this partner.'),
        ),
      );
      return;
    }

    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map application.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error opening map: $e')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'suspended':
        return Colors.deepOrange.shade700;
      case 'pending':
      default:
        return AppColors.malt;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade50;
      case 'rejected':
        return Colors.red.shade50;
      case 'suspended':
        return Colors.deepOrange.shade50;
      case 'pending':
      default:
        return AppColors.turmericLight;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return timestamp.toString();
  }

  void _showPartnerDetails(AdminOwnerModel owner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.maltBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Shop title & Status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.malt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_rounded,
                        color: AppColors.turmeric,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            owner.shopName.isEmpty
                                ? 'Unnamed Shop'
                                : owner.shopName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.malt,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Owner: ${owner.fullName}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.maltMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(owner.approvalStatus),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(owner.approvalStatus)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        owner.approvalStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _getStatusColor(owner.approvalStatus),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Information rows
                _buildDetailRow(
                  Icons.email_outlined,
                  'Email Address',
                  owner.email,
                ),
                _buildDetailRow(
                  Icons.phone_outlined,
                  'Mobile Number',
                  owner.mobile,
                ),
                if (owner.shopPhone.isNotEmpty)
                  _buildDetailRow(
                    Icons.call_outlined,
                    'Shop Phone / Landline',
                    owner.shopPhone,
                  ),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Shop Address',
                  '${owner.shopAddress.isNotEmpty ? '${owner.shopAddress}\n' : ''}${owner.city}, ${owner.state} - ${owner.pincode}',
                ),
                _buildDetailRow(
                  Icons.calendar_today_outlined,
                  'Registered On',
                  _formatDate(owner.createdAt),
                ),
                if (owner.latitude != 0 || owner.longitude != 0)
                  _buildDetailRow(
                    Icons.my_location_outlined,
                    'GPS Coordinates',
                    '${owner.latitude.toStringAsFixed(6)}, ${owner.longitude.toStringAsFixed(6)}',
                  ),

                const SizedBox(height: 12),

                // Map button
                OutlinedButton.icon(
                  onPressed: () =>
                      _openMapDirections(owner.latitude, owner.longitude),
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('View Shop Location on Google Maps'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Action buttons based on current status
                Text(
                  'Partner Account Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.malt.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),

                if (owner.approvalStatus.toLowerCase() == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _handleStatusChange(
                              owner.uid,
                              'rejected',
                              'Application Rejected',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Reject Application'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _handleStatusChange(
                              owner.uid,
                              'approved',
                              'Partner Approved Successfully',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Approve Partner'),
                        ),
                      ),
                    ],
                  ),
                ] else if (owner.approvalStatus.toLowerCase() ==
                    'approved') ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _handleStatusChange(
                        owner.uid,
                        'suspended',
                        'Partner Account Suspended',
                      );
                    },
                    icon: const Icon(Icons.block_rounded),
                    label: const Text('Suspend Partner Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _handleStatusChange(
                        owner.uid,
                        'approved',
                        'Partner Reactivated & Approved',
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Reactivate & Approve Partner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.maltMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.maltMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not Provided' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  Future<void> _handleStatusChange(
    String ownerId,
    String newStatus,
    String successMsg,
  ) async {
    final provider = Provider.of<AdminOwnerProvider>(context, listen: false);
    final success = await provider.updatePartnerStatus(
      ownerId: ownerId,
      status: newStatus,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: newStatus == 'approved'
              ? Colors.green.shade800
              : AppColors.malt,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Operation failed. Please try again.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Partners')),
      body: Consumer<AdminOwnerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.owners.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Compute counts
          final pendingCount = provider.pendingOwners.length;
          final approvedCount = provider.approvedOwners.length;
          final suspendedCount = provider.suspendedOrRejectedOwners.length;

          // Filter by tab
          List<AdminOwnerModel> filtered = provider.owners;
          if (_selectedFilter == 'pending') {
            filtered = provider.pendingOwners;
          } else if (_selectedFilter == 'approved') {
            filtered = provider.approvedOwners;
          } else if (_selectedFilter == 'suspended') {
            filtered = provider.suspendedOrRejectedOwners;
          }

          // Filter by search query
          if (_searchQuery.trim().isNotEmpty) {
            final q = _searchQuery.toLowerCase().trim();
            filtered = filtered.where((o) {
              return o.shopName.toLowerCase().contains(q) ||
                  o.fullName.toLowerCase().contains(q) ||
                  o.email.toLowerCase().contains(q) ||
                  o.city.toLowerCase().contains(q) ||
                  o.mobile.contains(q);
            }).toList();
          }

          return RefreshIndicator(
            onRefresh: () => provider.getOwners(),
            color: AppColors.turmeric,
            child: Column(
              children: [
                // Search bar & Filter row
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Search TextField
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search partner, shop, city...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'all',
                              'All (${provider.owners.length})',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'pending',
                              'Pending ($pendingCount)',
                              badge: pendingCount > 0,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'approved',
                              'Approved ($approvedCount)',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'suspended',
                              'Suspended ($suspendedCount)',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Partner list or empty state
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(32),
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
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No partners match "$_searchQuery"'
                                      : _selectedFilter == 'pending'
                                      ? 'No Pending Applications'
                                      : 'No Partner Accounts Found',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.malt,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedFilter == 'pending'
                                      ? 'All vehicle partner applications have been reviewed.'
                                      : 'Registered partner accounts will appear here.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.maltMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final owner = filtered[index];
                            final status = owner.approvalStatus.toLowerCase();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: status == 'pending'
                                      ? AppColors.turmeric
                                      : AppColors.maltBorder.withValues(
                                          alpha: 0.7,
                                        ),
                                  width: status == 'pending' ? 1.5 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _showPartnerDetails(owner),
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: AppColors.malt,
                                              borderRadius:
                                                  BorderRadius.circular(14),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  owner.shopName.isEmpty
                                                      ? 'Unnamed Shop'
                                                      : owner.shopName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.malt,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${owner.fullName} • ${owner.city}, ${owner.state}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.maltMuted,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Email: ${owner.email}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.maltMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusBgColor(
                                                owner.approvalStatus,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              owner.approvalStatus
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: _getStatusColor(
                                                  owner.approvalStatus,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),

                                      // Actions toolbar
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone_rounded,
                                                size: 15,
                                                color: AppColors.maltMuted,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                owner.mobile,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.malt,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              if (status == 'pending') ...[
                                                TextButton(
                                                  onPressed: () =>
                                                      _handleStatusChange(
                                                        owner.uid,
                                                        'rejected',
                                                        'Application rejected',
                                                      ),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.red.shade700,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                  ),
                                                  child: const Text('Reject'),
                                                ),
                                                const SizedBox(width: 6),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _handleStatusChange(
                                                        owner.uid,
                                                        'approved',
                                                        'Partner approved successfully',
                                                      ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 6,
                                                        ),
                                                    minimumSize: Size.zero,
                                                  ),
                                                  child: const Text(
                                                    'Approve',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ] else ...[
                                                TextButton.icon(
                                                  onPressed: () =>
                                                      _showPartnerDetails(
                                                        owner,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.visibility_outlined,
                                                    size: 15,
                                                  ),
                                                  label: const Text(
                                                    'Details',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.malt,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    String filterKey,
    String label, {
    bool badge = false,
  }) {
    final isSelected = _selectedFilter == filterKey;

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.malt : AppColors.maltMuted,
            ),
          ),
          if (badge) ...[
            const SizedBox(width: 4),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.turmeric,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppColors.maltLight.withValues(alpha: 0.05),
      selectedColor: AppColors.turmeric.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? AppColors.turmeric
              : AppColors.maltBorder.withValues(alpha: 0.6),
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
    );
  }
}
