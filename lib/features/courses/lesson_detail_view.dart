import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import '../../shared/utils.dart';

class LessonDetailView extends ConsumerStatefulWidget {
  final String lessonId;
  final String courseId;

  const LessonDetailView({
    super.key,
    required this.lessonId,
    required this.courseId,
  });

  @override
  ConsumerState<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends ConsumerState<LessonDetailView>
    with SingleTickerProviderStateMixin {
  String selectedTab = 'Overview';
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonDetailProvider(widget.lessonId));
    final courseDetailState = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SlideTransition(
        position: _slideAnimation,
        child: lessonState.when(
          data: (lesson) => courseDetailState.when(
            data: (courseDetail) => _buildContent(context, lesson, courseDetail),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF581C87)),
            ),
            error: (error, stack) =>
                const Center(child: Text('Error loading course')),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF581C87)),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Lesson lesson, CourseDetail courseDetail) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, lesson),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLessonInfo(lesson),
              const SizedBox(height: 24),
              _buildTabs(context),
              const SizedBox(height: 16),
              if (selectedTab == 'Overview')
                _buildLessonContent(lesson)
              else
                _buildReviewsContent(lesson),
              const SizedBox(height: 24),
              _buildNavigationButtons(context, lesson, courseDetail),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Lesson lesson) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF0A1929),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF0A1929),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.white54,
                ),
                const SizedBox(height: 16),
                Text(
                  '${lesson.durationMinutes}m',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonInfo(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF581C87).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: Color(0xFF581C87)),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.durationMinutes}m',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF581C87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lesson.isFree
                      ? Colors.green
                      : _getPlanColor(lesson.plan),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lesson.isFree ? 'FREE' : lesson.plan.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Lesson ${lesson.lessonNumber}: "${lesson.title}"',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = 'Overview';
              });
            },
            child: _buildTab('Overview', selectedTab == 'Overview'),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = 'Reviews';
              });
            },
            child: _buildTab('Reviews', selectedTab == 'Reviews'),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF581C87) : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        if (isActive)
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF581C87),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }

  Widget _buildLessonContent(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lesson Content',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Course Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Student will learn ${lesson.title.toLowerCase()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsContent(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Ratings & Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Average rating display
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating number
              Column(
                children: [
                  const Text(
                    '4.5',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.amber[700],
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12 reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),

              // Rating bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 8, 12),
                    _buildRatingBar(4, 3, 12),
                    _buildRatingBar(3, 1, 12),
                    _buildRatingBar(2, 0, 12),
                    _buildRatingBar(1, 0, 12),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Individual reviews
          _buildReviewCard(
            'Sarah Johnson',
            5,
            'Excellent lesson! Very clear explanations and great examples.',
            '2 days ago',
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Mike Chen',
            4,
            'Good content, but could use more practical exercises.',
            '1 week ago',
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Emma Wilson',
            5,
            'This lesson helped me understand the concept perfectly. Highly recommended!',
            '2 weeks ago',
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(Colors.amber[700]!),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      String userName, int rating, String comment, String timeAgo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF581C87),
                child: Text(
                  userName[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber[700],
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, Lesson lesson, CourseDetail courseDetail) {
    final currentIndex =
        courseDetail.lessons.indexWhere((l) => l.id == lesson.id);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < courseDetail.lessons.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: hasPrevious
                  ? () async {
                      final previousLesson =
                          courseDetail.lessons[currentIndex - 1];
                      
                      // Animate current page out to the right
                      setState(() {
                        _slideAnimation = Tween<Offset>(
                          begin: Offset.zero,
                          end: const Offset(1.0, 0.0),
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeInOut,
                        ));
                      });
                      
                      // Start animation and navigate
                      _slideController.forward().then((_) {
                        Navigator.of(context).pushReplacement(
                          slideLeftRoute(
                            LessonDetailView(
                              lessonId: previousLesson.id,
                              courseId: widget.courseId,
                            ),
                          ),
                        );
                      });
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: hasPrevious
                      ? const Color(0xFF581C87)
                      : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: hasPrevious
                        ? const Color(0xFF581C87)
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasPrevious
                          ? const Color(0xFF581C87)
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: hasNext
                  ? () async {
                      final nextLesson = courseDetail.lessons[currentIndex + 1];
                      
                      // Animate current page out to the left
                      setState(() {
                        _slideAnimation = Tween<Offset>(
                          begin: Offset.zero,
                          end: const Offset(-1.0, 0.0),
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeInOut,
                        ));
                      });
                      
                      // Start animation and navigate
                      _slideController.forward().then((_) {
                        Navigator.of(context).pushReplacement(
                          slideRightRoute(
                            LessonDetailView(
                              lessonId: nextLesson.id,
                              courseId: widget.courseId,
                            ),
                          ),
                        );
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    hasNext ? const Color(0xFF581C87) : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next Lesson',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasNext ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: hasNext ? Colors.white : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'core':
        return const Color(0xFF9D65AA);
      case 'pro':
        return const Color(0xFF581C87);
      case 'elite':
        return Colors.amber.shade700;
      default:
        return Colors.grey;
    }
  }
}