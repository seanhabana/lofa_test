import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import '../../shared/utils.dart';
import 'lesson_detail_view.dart';

class CourseDetailView extends ConsumerWidget {
  final String courseId;

  const CourseDetailView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseDetailState = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      body: courseDetailState.when(
        data: (data) => _buildContent(context, data),
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
    );
  }

  Widget _buildContent(BuildContext context, CourseDetail courseDetail) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, courseDetail.course),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseInfo(courseDetail),
              const SizedBox(height: 24),
              _buildProgressSection(courseDetail),
              const SizedBox(height: 24),
              _buildLessonsSection(context, courseDetail),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Course course) {
  return SliverAppBar(
    expandedHeight: 200,
    pinned: true,
    backgroundColor: const Color(0xFF581C87),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),

    /// ❌ Prevent default big Material spacing
    titleSpacing: 0,

    flexibleSpace: LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed =
            constraints.biggest.height <= kToolbarHeight + 10;

        return FlexibleSpaceBar(
          centerTitle: false,

          /// 🔥 Dynamic padding
          titlePadding: EdgeInsets.only(
            left: isCollapsed ? 56 : 16, // back button width ≈ 56
            right: 16,
            bottom: 16,
          ),

          title: Text(
            course.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          background: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF581C87).withOpacity(0.8),
                    ],
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

  Widget _buildCourseInfo(CourseDetail courseDetail) {
    final course = courseDetail.course;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 20, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                course.rating.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                course.durationHours,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.menu_book, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${course.totalLessons} lessons',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            course.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(CourseDetail courseDetail) {
    final percent = (courseDetail.progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF581C87).withOpacity(0.12),
            const Color(0xFF9D65AA).withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: courseDetail.progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF581C87)),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF581C87),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Progress info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF581C87),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${courseDetail.completedLessons} of ${courseDetail.lessons.length} lessons completed',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  percent == 100
                      ? '🎉 Course completed!'
                      : 'Keep going, you\'re doing great!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsSection(BuildContext context, CourseDetail courseDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Lessons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: courseDetail.lessons.length,
          itemBuilder: (context, index) {
            return _buildLessonCard(context, courseDetail.lessons[index]);
          },
        ),
      ],
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          slideUpRoute(
            LessonDetailView(
              lessonId: lesson.id,
              courseId: courseId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: lesson.isCompleted
                ? const Color(0xFF581C87)
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: lesson.isCompleted
                    ? const Color(0xFF581C87)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: lesson.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${lesson.lessonNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lesson.isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (!lesson.isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPlanColor(lesson.plan),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            lesson.plan.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VIDEO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.durationMinutes}m',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
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