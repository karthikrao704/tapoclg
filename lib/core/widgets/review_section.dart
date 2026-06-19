import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/add_review_modal.dart';

class ReviewItem {
  final String authorName;
  final String date;
  final double rating;
  final String comment;
  final String? avatarUrl;

  const ReviewItem({
    required this.authorName,
    required this.date,
    required this.rating,
    required this.comment,
    this.avatarUrl,
  });
}

class ReviewSection extends StatelessWidget {
  final String title;
  final List<ReviewItem> reviews;
  final double averageRating;
  final String? moduleType;
  final String? itemTitle;

  const ReviewSection({
    super.key,
    required this.title,
    required this.reviews,
    required this.averageRating,
    this.moduleType,
    this.itemTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 35,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppFonts.poppinsSemiBold(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            if (moduleType != null && itemTitle != null)
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddReviewModal(
                      moduleType: moduleType!,
                      itemTitle: itemTitle!,
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note, size: 18),
                label: Text(
                  'Add Review',
                  style: AppFonts.poppinsSemiBold(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor.withAlpha(100)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (reviews.isNotEmpty)
          Row(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: AppFonts.poppinsSemiBold(
                  fontSize: 32,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor()
                            ? Icons.star
                            : (index < averageRating ? Icons.star_half : Icons.star_border),
                        color: const Color(0xFFF59E0B),
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Based on ${reviews.length} reviews',
                    style: AppFonts.poppinsRegular(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 24),
        ...reviews.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryColor.withAlpha(40),
                      backgroundImage: review.avatarUrl != null ? NetworkImage(review.avatarUrl!) : null,
                      child: review.avatarUrl == null
                          ? Text(
                              review.authorName.isNotEmpty ? review.authorName[0].toUpperCase() : '?',
                              style: AppFonts.poppinsSemiBold(
                                color: AppColors.primaryColor,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.authorName,
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            review.date,
                            style: AppFonts.poppinsRegular(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.comment,
                  style: AppFonts.poppinsRegular(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class MockReviews {
  static const List<ReviewItem> serviceReviews = [
    ReviewItem(
      authorName: "Priya Sharma",
      date: "2 days ago",
      rating: 5.0,
      comment: "Absolutely rejuvenating. The therapists were highly professional and the ambiance was incredibly soothing. Will definitely book again.",
    ),
    ReviewItem(
      authorName: "Rahul Desai",
      date: "1 week ago",
      rating: 4.0,
      comment: "Great experience overall. The massage really helped relieve my muscle tension after a long work week.",
    ),
  ];

  static const List<ReviewItem> workshopFeedback = [
    ReviewItem(
      authorName: "Ananya Patel",
      date: "3 weeks ago",
      rating: 5.0,
      comment: "The instructor was very knowledgeable and the pacing was perfect for beginners. I learned so much about breathwork.",
    ),
    ReviewItem(
      authorName: "Vikram Singh",
      date: "1 month ago",
      rating: 5.0,
      comment: "Transformative workshop! The practical exercises were easy to follow and incredibly effective.",
    ),
  ];

  static const List<ReviewItem> packageTestimonials = [
    ReviewItem(
      authorName: "Sneha Reddy",
      date: "1 month ago",
      rating: 5.0,
      comment: "This package completely revitalized me. The holistic approach spanning multiple days was exactly what my body needed.",
    ),
    ReviewItem(
      authorName: "Amit Verma",
      date: "2 months ago",
      rating: 4.5,
      comment: "Excellent value for the treatments included. I feel much lighter and more focused after completing the program.",
    ),
  ];

  static const List<ReviewItem> blogFeedback = [
    ReviewItem(
      authorName: "Kavita Nair",
      date: "5 days ago",
      rating: 5.0,
      comment: "Very insightful read! I've started incorporating these Ayurvedic tips into my morning routine and I can already feel the difference.",
    ),
    ReviewItem(
      authorName: "Deepak Mehta",
      date: "2 weeks ago",
      rating: 4.0,
      comment: "Well-researched and easy to understand. Looking forward to more articles on this topic.",
    ),
  ];
}
