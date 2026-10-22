import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/complaint_model.dart';
import '../provider/admin_complaint_provider.dart';
import '../../theme/app_theme.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  late Future<List<ComplaintModel>> complaintsFuture;

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  void loadComplaints() {
    complaintsFuture = Provider.of<AdminComplaintProvider>(
      context,
      listen: false,
    ).getComplaints();
  }

  void refreshComplaints() {
    setState(() {
      loadComplaints();
    });
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Color statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return AppColors.successLight;
      case 'in_progress':
        return AppColors.warningLight;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return AppColors.infoLight;
    }
  }

  Future<void> changeStatus(String complaintId, String status) async {
    final provider = Provider.of<AdminComplaintProvider>(
      context,
      listen: false,
    );

    final success = await provider.updateComplaintStatus(
      complaintId: complaintId,
      status: status,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint marked as ${status.replaceAll('_', ' ')}'),
        ),
      );
      refreshComplaints();
    }
  }

  Future<void> replyToComplaint(ComplaintModel complaint) async {
    final controller = TextEditingController(text: complaint.adminReply);

    final reply = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reply to Complaint'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter official admin response...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Send Reply'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reply == null || reply.trim().isEmpty || !mounted) return;

    final provider = Provider.of<AdminComplaintProvider>(
      context,
      listen: false,
    );

    final success = await provider.replyToComplaint(
      complaintId: complaint.id,
      reply: reply.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply submitted successfully')),
      );
      refreshComplaints();
    }
  }

  Future<void> deleteComplaint(String complaintId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Complaint Record?'),
          content: const Text('Are you sure you want to permanently delete this complaint?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final provider = Provider.of<AdminComplaintProvider>(
      context,
      listen: false,
    );

    final success = await provider.deleteComplaint(complaintId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint deleted')),
      );
      refreshComplaints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Complaints'),
        actions: [
          IconButton(
            onPressed: refreshComplaints,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<ComplaintModel>>(
        future: complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.turmeric),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final complaints = snapshot.data ?? [];

          if (complaints.isEmpty) {
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
                      Icons.sentiment_satisfied_alt_rounded,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Complaints Filed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All user interactions and rental bookings are running smoothly.',
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
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final statusClr = statusColor(complaint.status);
              final statusBg = statusBgColor(complaint.status);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: AppColors.maltBorder.withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              complaint.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.malt,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              complaint.status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                color: statusClr,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By: ${complaint.submittedBy} • User: ${complaint.userId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.maltMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.maltBorder),
                        ),
                        child: Text(
                          complaint.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.malt,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (complaint.adminReply.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.turmericLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.turmeric),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Official Admin Reply:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.malt,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                complaint.adminReply,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.malt,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => replyToComplaint(complaint),
                            icon: const Icon(Icons.reply_rounded, size: 16),
                            label: const Text('Reply', style: TextStyle(fontSize: 13)),
                          ),
                          if (complaint.status != 'in_progress')
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () => changeStatus(complaint.id, 'in_progress'),
                              child: const Text('In Progress', style: TextStyle(fontSize: 13)),
                            ),
                          if (complaint.status != 'resolved')
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                foregroundColor: AppColors.success,
                                side: const BorderSide(color: AppColors.success),
                              ),
                              onPressed: () => changeStatus(complaint.id, 'resolved'),
                              child: const Text('Resolve', style: TextStyle(fontSize: 13)),
                            ),
                          if (complaint.status != 'rejected')
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              onPressed: () => changeStatus(complaint.id, 'rejected'),
                              child: const Text('Reject', style: TextStyle(fontSize: 13)),
                            ),
                          IconButton(
                            onPressed: () => deleteComplaint(complaint.id),
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            tooltip: 'Delete Complaint',
                          ),
                        ],
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