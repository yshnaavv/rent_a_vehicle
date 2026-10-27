import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/review_model.dart';
import '../provider/admin_review_provider.dart';
import '../../theme/app_theme.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late Future<List<ReviewModel>> reviewsFuture;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  void loadReviews() {
    reviewsFuture = Provider.of<AdminReviewProvider>(
      context,
      listen: false,
    ).getReviews();
  }

  void refreshReviews() {
    setState(() {
      loadReviews();
    });
  }

  Future<void> approveReview(String reviewId) async {
    bool success = await Provider.of<AdminReviewProvider>(
      context,
      listen: false,
    ).approveReview(reviewId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review approved successfully')),
      );
      refreshReviews();
    }
  }

  Future<void> rejectReview(String reviewId) async {
    bool success = await Provider.of<AdminReviewProvider>(
      context,
      listen: false,
    ).rejectReview(reviewId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review rejected')));
      refreshReviews();
    }
  }

  Future<void> deleteReview(String reviewId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Review?'),
          content: const Text(
            'Are you sure you want to permanently delete this customer review?',
          ),
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

    bool success = await Provider.of<AdminReviewProvider>(
      context,
      listen: false,
    ).deleteReview(reviewId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review removed')));
      refreshReviews();
    }
  }

  Widget buildRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round()
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          color: AppColors.turmeric,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        actions: [
          IconButton(
            onPressed: refreshReviews,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.turmeric),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
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
                      Icons.star_outline_rounded,
                      size: 56,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Reviews Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Customer ratings and reviews will be displayed here.',
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

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
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.malt,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.turmeric,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName.isEmpty
                                        ? 'Verified User'
                                        : review.userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.malt,
                                    ),
                                  ),
                                  Text(
                                    'Vehicle: ${review.vehicleName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.maltMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: review.isApproved
                                  ? AppColors.successLight
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              review.isApproved ? 'APPROVED' : 'PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: review.isApproved
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      buildRating(review.rating),
                      const SizedBox(height: 10),
                      Text(
                        review.comment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.malt,
                          height: 1.4,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!review.isApproved)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () => approveReview(review.id),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text(
                                'Approve',
                                style: TextStyle(fontSize: 13),
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                foregroundColor: AppColors.warning,
                                side: const BorderSide(
                                  color: AppColors.warning,
                                ),
                              ),
                              onPressed: () => rejectReview(review.id),
                              icon: const Icon(Icons.block, size: 16),
                              label: const Text(
                                'Revoke',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () => deleteReview(review.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            tooltip: 'Delete review',
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
