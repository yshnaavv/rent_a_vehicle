import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/model/complaint_model.dart';
import '../model/booking_model.dart';
import '../provider/booking_provider.dart';
import '../provider/user_complaint_provider.dart';
import '../../theme/app_theme.dart';

class UserComplaintScreen extends StatefulWidget {
  final String? preSelectedBookingId;
  final String? preSelectedVehicleId;
  final String? preSelectedOwnerId;
  final String? preSelectedSubject;

  const UserComplaintScreen({
    super.key,
    this.preSelectedBookingId,
    this.preSelectedVehicleId,
    this.preSelectedOwnerId,
    this.preSelectedSubject,
  });

  @override
  State<UserComplaintScreen> createState() => _UserComplaintScreenState();
}

class _UserComplaintScreenState extends State<UserComplaintScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  BookingModel? _selectedBooking;
  bool _hasPreSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.preSelectedSubject != null) {
      _subjectController.text = widget.preSelectedSubject!;
    }

    Future.microtask(() async {
      if (!mounted) return;
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      if (bookingProvider.bookings.isEmpty) {
        await bookingProvider.getMyBookings();
      }

      if (!mounted) return;

      final complaintProvider = Provider.of<UserComplaintProvider>(
        context,
        listen: false,
      );
      await complaintProvider.getMyComplaints();

      if (widget.preSelectedBookingId != null && !_hasPreSelected && mounted) {
        final matches = bookingProvider.bookings.where(
          (b) => b.id == widget.preSelectedBookingId,
        );
        if (matches.isNotEmpty) {
          setState(() {
            _selectedBooking = matches.first;
            _hasPreSelected = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.malt;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return AppColors.successLight;
      case 'in_progress':
        return AppColors.warningLight;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return AppColors.turmericLight;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return timestamp.toString();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<UserComplaintProvider>(context, listen: false);

    final success = await provider.submitComplaint(
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      bookingId: _selectedBooking?.id ?? widget.preSelectedBookingId,
      vehicleId: _selectedBooking?.vehicleId ?? widget.preSelectedVehicleId,
      ownerId: _selectedBooking?.ownerId ?? widget.preSelectedOwnerId,
    );

    if (!mounted) return;

    if (success) {
      _subjectController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedBooking = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your complaint has been submitted to the Admin team.'),
          backgroundColor: AppColors.malt,
        ),
      );

      // Switch to history tab
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Submission failed. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support & Complaints'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.turmeric,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.turmeric,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'File Complaint', icon: Icon(Icons.edit_note_rounded)),
            Tab(text: 'My Complaints', icon: Icon(Icons.history_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFormTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Consumer<UserComplaintProvider>(
        builder: (context, complaintProvider, child) {
          final bookingProvider = Provider.of<BookingProvider>(context);

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.maltBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.turmericLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: AppColors.malt,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direct Admin Resolution',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.malt,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Submit issues regarding vehicles, rentals, or partners directly to administrators.',
                              style: TextStyle(
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

                const SizedBox(height: 24),

                // Subject Field
                const Text(
                  'Complaint Subject *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.malt,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. Vehicle breakdown, delayed handover, cleanliness',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a complaint subject';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Related Booking Selection (Optional)
                const Text(
                  'Related Booking (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.malt,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<BookingModel?>(
                  initialValue: _selectedBooking,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.bookmark_border_rounded),
                  ),
                  hint: const Text('Select a related reservation (Optional)'),
                  items: [
                    const DropdownMenuItem<BookingModel?>(
                      value: null,
                      child: Text('General Platform Issue (No booking)'),
                    ),
                    ...bookingProvider.bookings.map((booking) {
                      return DropdownMenuItem<BookingModel?>(
                        value: booking,
                        child: Text(
                          '${booking.vehicleName} (${booking.shopName})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedBooking = val;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Description Field
                const Text(
                  'Detailed Description *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.malt,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe what happened in detail, including dates, partner responses, or any specific concerns...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a detailed description';
                    }
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: complaintProvider.isSubmitting
                        ? null
                        : _submitComplaint,
                    child: complaintProvider.isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.malt,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Submitting Complaint...'),
                            ],
                          )
                        : const Text(
                            'Submit Complaint to Admin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<UserComplaintProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.turmeric),
          );
        }

        if (provider.myComplaints.isEmpty) {
          return Center(
            child: SingleChildScrollView(
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
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Complaints Filed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You have not submitted any complaints yet. All reported issues and admin replies will show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.getMyComplaints(),
          color: AppColors.turmeric,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myComplaints.length,
            itemBuilder: (context, index) {
              final complaint = provider.myComplaints[index];
              return _buildComplaintCard(complaint);
            },
          ),
        );
      },
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    final status = complaint.status.toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.maltBorder.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBgColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _statusColor(status),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  _formatDate(complaint.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.maltMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Subject
            Text(
              complaint.subject,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.malt,
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              complaint.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.maltMuted,
                height: 1.35,
              ),
            ),

            if (complaint.bookingId.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_outline,
                    size: 15,
                    color: AppColors.maltMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Booking ID: ${complaint.bookingId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.maltMuted,
                    ),
                  ),
                ],
              ),
            ],

            // Admin Reply Section
            if (complaint.adminReply.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.turmericLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.turmeric.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 18,
                          color: AppColors.malt,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Official Admin Response',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.malt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaint.adminReply,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.malt,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
