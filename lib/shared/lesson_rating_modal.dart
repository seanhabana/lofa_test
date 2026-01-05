// lib/shared/modals/lesson_rating_modal.dart

import 'package:flutter/material.dart';

class LessonRatingModal extends StatefulWidget {
  final int lessonId;
  final int courseId;
  final VoidCallback? onRatingSubmitted;

  const LessonRatingModal({
    super.key,
    required this.lessonId,
    required this.courseId,
    this.onRatingSubmitted,
  });

  @override
  State<LessonRatingModal> createState() => _LessonRatingModalState();
}

class _LessonRatingModalState extends State<LessonRatingModal> {
  int _rating = 0;
  int _hoveredRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement API call to submit lesson rating
      // await CourseService.submitLessonRating(
      //   lessonId: widget.lessonId,
      //   courseId: widget.courseId,
      //   rating: _rating,
      //   review: _reviewController.text.trim(),
      //   token: token,
      // );

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        widget.onRatingSubmitted?.call();
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate This Lesson',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF581C87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'How would you rate this lesson?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final isActive = starValue <= (_hoveredRating > 0 ? _hoveredRating : _rating);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starValue;
                    });
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _hoveredRating = starValue;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _hoveredRating = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isActive ? Icons.star : Icons.star_border,
                        size: 40,
                        color: isActive ? Colors.amber : Colors.grey[400],
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _getRatingText(_rating),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF581C87),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Optional Review
            TextField(
              controller: _reviewController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your thoughts (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF581C87), width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF581C87)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: Color(0xFF581C87)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _rating == 0 || _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF581C87),
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
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
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