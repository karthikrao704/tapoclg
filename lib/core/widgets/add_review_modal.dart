import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/repositories/review_repository.dart';
import 'package:tapovana_mobile_app/core/storage/local_database.dart';

class AddReviewModal extends StatefulWidget {
  final String moduleType;
  final String itemTitle;

  const AddReviewModal({
    super.key,
    required this.moduleType,
    required this.itemTitle,
  });

  @override
  State<AddReviewModal> createState() => _AddReviewModalState();
}

class _AddReviewModalState extends State<AddReviewModal> {
  final _formKey = GlobalKey<FormState>();
  final _reviewRepo = ReviewRepository();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _feedbackController;

  int _rating = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _feedbackController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await LocalDatabase.getUserName();
    final email = await LocalDatabase.getUserEmail();
    if (mounted) {
      setState(() {
        if (name != null) _nameController.text = name;
        if (email != null) _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _reviewRepo.submitReview(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        moduleType: widget.moduleType,
        title: widget.itemTitle,
        rating: _rating,
        feedback: _feedbackController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit review. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave a Review',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 20,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Reviewing: ${widget.itemTitle}',
                style: AppFonts.poppinsMedium(
                  fontSize: 14,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter your email';
                  if (!val.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Star Rating
              Text(
                'Your Rating',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              // Feedback Field
              TextFormField(
                controller: _feedbackController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Your Feedback',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter your feedback' : null,
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Review',
                          style: AppFonts.poppinsSemiBold(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
