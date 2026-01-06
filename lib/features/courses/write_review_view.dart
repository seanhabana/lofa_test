import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/star_rating.dart';
import '../../services/course_service.dart';
import '../../providers/auth_session_provider.dart';

class WriteReviewView extends ConsumerStatefulWidget {
  final int courseId;
  final String courseTitle;

  const WriteReviewView({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  ConsumerState<WriteReviewView> createState() => _WriteReviewViewState();
}

class _WriteReviewViewState extends ConsumerState<WriteReviewView> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authState = ref.read(authSessionProvider);
    final token = authState.token;

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit a review')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }

    try {
      final success = await CourseService.submitReview(
        courseId: widget.courseId,
        rating: _rating,
        review: _commentController.text.trim(),
        isAnonymous: _isAnonymous,
        token: token,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Review submitted successfully! 🎉'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit review. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: const Color(0xFF581C87),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Course Title
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF581C87).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.courseTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF581C87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rating Section
            const Text(
              'How would you rate this course?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: StarRating(
                rating: _rating,
                size: 50,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingLabel(_rating),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Comment Section
            const Text(
              'Share your experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentController,
              maxLines: 8,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Tell us what you liked or what could be improved...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF581C87), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write your review';
                }
                if (value.trim().length < 10) {
                  return 'Review must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Anonymous Option
            CheckboxListTile(
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value ?? false;
                });
              },
              title: const Text('Post anonymously'),
              subtitle: const Text('Your name will not be shown with this review'),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF581C87),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF581C87),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
