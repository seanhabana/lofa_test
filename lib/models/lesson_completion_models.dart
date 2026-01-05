// Add this to your models folder: lib/models/lesson_completion_models.dart

/// Response from backend when marking lesson as completed
/// Matches Laravel backend response structure
class LessonCompletionResponse {
  final String message;
  final LessonProgressData progress;
  final EnrollmentData enrollment;
  final bool courseCompleted;
  final bool showCompletionModal;

  LessonCompletionResponse({
    required this.message,
    required this.progress,
    required this.enrollment,
    required this.courseCompleted,
    required this.showCompletionModal,
  });

  factory LessonCompletionResponse.fromJson(Map<String, dynamic> json) {
    return LessonCompletionResponse(
      message: json['message'] ?? '',
      progress: LessonProgressData.fromJson(json['progress'] ?? {}),
      enrollment: EnrollmentData.fromJson(json['enrollment'] ?? {}),
      courseCompleted: json['course_completed'] ?? false,
      showCompletionModal: json['show_completion_modal'] ?? false,
    );
  }
}

/// Lesson progress data from backend
class LessonProgressData {
  final int id;
  final int userId;
  final int courseEnrollmentId;
  final int courseLessonId;
  final String status;
  final int progressPercent;
  final int timeSpentSeconds;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;

  LessonProgressData({
    required this.id,
    required this.userId,
    required this.courseEnrollmentId,
    required this.courseLessonId,
    required this.status,
    required this.progressPercent,
    required this.timeSpentSeconds,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonProgressData.fromJson(Map<String, dynamic> json) {
    return LessonProgressData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseEnrollmentId: json['course_enrollment_id'] ?? 0,
      courseLessonId: json['course_lesson_id'] ?? 0,
      status: json['status'] ?? 'not_started',
      progressPercent: json['progress_percent'] ?? 0,
      timeSpentSeconds: json['time_spent_seconds'] ?? 0,
      completedAt: json['completed_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isNotStarted => status == 'not_started';
}

/// Course enrollment data from backend
class EnrollmentData {
  final int id;
  final int userId;
  final int courseId;
  final double progressPercentage;
  final bool hasRatedCourse;
  final String enrolledAt;
  final String? completedAt;
  final String? lastAccessedAt;

  EnrollmentData({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.progressPercentage,
    required this.hasRatedCourse,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory EnrollmentData.fromJson(Map<String, dynamic> json) {
    return EnrollmentData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
      hasRatedCourse: json['has_rated_course'] ?? false,
      enrolledAt: json['enrolled_at'] ?? '',
      completedAt: json['completed_at'],
      lastAccessedAt: json['last_accessed_at'],
    );
  }

  bool get isCourseCompleted => progressPercentage >= 100;
}