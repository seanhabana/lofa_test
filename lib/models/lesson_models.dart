// ==================== LESSON MODELS ====================

import 'course_models.dart';

class Lesson {
  final int id;
  final int courseModuleId;
  final String title;
  final String content;
  final String type;
  final String difficulty;
  final String videoUrl;
  final int durationMinutes;
  final int sortOrder;
  final bool isPreview;
  final bool isPublished;
  final int requiredSubscriptionTier;
  final String formattedVideoUrl;
  final bool accessBlocked;
  final bool userHasAccess;
  final int requiredTierLevel;
  final int userTierLevel;
  final String createdAt;
  final String updatedAt;

  Lesson({
    required this.id,
    required this.courseModuleId,
    required this.title,
    required this.content,
    required this.type,
    required this.difficulty,
    required this.videoUrl,
    required this.durationMinutes,
    required this.sortOrder,
    required this.isPreview,
    required this.isPublished,
    required this.requiredSubscriptionTier,
    required this.formattedVideoUrl,
    required this.accessBlocked,
    required this.userHasAccess,
    required this.requiredTierLevel,
    required this.userTierLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      courseModuleId: json['course_module_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'video',
      difficulty: json['difficulty'] ?? 'basic',
      videoUrl: json['video_url'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
      isPreview: json['is_preview'] ?? false,
      isPublished: json['is_published'] ?? false,
      requiredSubscriptionTier: json['required_subscription_tier'] ?? 0,
      formattedVideoUrl: json['formatted_video_url'] ?? json['video_url'] ?? '',
      accessBlocked: json['access_blocked'] ?? false,
      userHasAccess: json['user_has_access'] ?? true,
      requiredTierLevel: json['required_tier_level'] ?? 0,
      userTierLevel: json['user_tier_level'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Helper getters
  bool get isFree => requiredSubscriptionTier == 0 || isPreview;
  
  String get plan {
    if (isFree) return 'free';
    switch (requiredSubscriptionTier) {
      case 1:
        return 'core';
      case 2:
        return 'pro';
      case 3:
        return 'elite';
      default:
        return 'free';
    }
  }

  int get lessonNumber => sortOrder;
}

// ==================== MODULE MODEL ====================

class CourseModule {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final int sortOrder;
  final bool isPublished;
  final List<Lesson> lessons;
  final String createdAt;
  final String updatedAt;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.isPublished,
    required this.lessons,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      isPublished: json['is_published'] ?? false,
      lessons: (json['lessons'] as List?)
          ?.map((l) => Lesson.fromJson(l))
          .toList() ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// ==================== COURSE DETAIL MODEL ====================

class CourseDetail {
  final Course course;
  final List<CourseModule> modules;
  final UserAccess userAccess;
  final UserProgress userProgress;

  CourseDetail({
    required this.course,
    required this.modules,
    required this.userAccess,
    required this.userProgress,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    // Parse the course data
    final courseData = json['course'] ?? json;
    
    // Parse modules from course data
    final modules = (courseData['modules'] as List?)
        ?.map((m) => CourseModule.fromJson(m))
        .toList() ?? [];
    
    // Create Course object with modules included
    final course = Course.fromJson(courseData);

    return CourseDetail(
      course: course,
      modules: modules,
      userAccess: UserAccess.fromJson(json['user_access'] ?? {}),
      userProgress: UserProgress.fromJson(json['user_progress'] ?? {}),
    );
  }

  // Flatten all lessons from all modules
  List<Lesson> get lessons {
    return modules.expand((module) => module.lessons).toList();
  }

  // Progress helpers
  double get progress => (userProgress.progressPercentage / 100).clamp(0.0, 1.0);
  int get completedLessons => userProgress.completedLessons;
}

// ==================== USER ACCESS MODEL ====================

class UserAccess {
  final bool hasAccess;
  final bool isEnrolled;
  final String requiredPlan;
  final int requiredTierLevel;
  final int userTierLevel;
  final String userSubscriptionStatus;

  UserAccess({
    required this.hasAccess,
    required this.isEnrolled,
    required this.requiredPlan,
    required this.requiredTierLevel,
    required this.userTierLevel,
    required this.userSubscriptionStatus,
  });

  factory UserAccess.fromJson(Map<String, dynamic> json) {
    return UserAccess(
      hasAccess: json['has_access'] ?? false,
      isEnrolled: json['is_enrolled'] ?? false,
      requiredPlan: json['required_plan'] ?? 'free',
      requiredTierLevel: json['required_tier_level'] ?? 0,
      userTierLevel: json['user_tier_level'] ?? 0,
      userSubscriptionStatus: json['user_subscription_status'] ?? 'inactive',
    );
  }
}

// ==================== USER PROGRESS MODEL ====================

class UserProgress {
  final int progressPercentage;
  final int completedLessons;
  final int totalLessons;
  final List<int> completedLessonsIds;
  final String? enrollmentDate;

  UserProgress({
    required this.progressPercentage,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedLessonsIds,
    this.enrollmentDate,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      progressPercentage: json['progress_percentage'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
      completedLessonsIds: (json['completed_lessons_ids'] as List?)
          ?.map((id) => id as int)
          .toList() ?? [],
      enrollmentDate: json['enrollment_date'],
    );
  }

  bool isLessonCompleted(int lessonId) {
    return completedLessonsIds.contains(lessonId);
  }
}

// ==================== LESSON PROGRESS REQUEST ====================

class LessonProgressRequest {
  final int watchTimeSeconds;
  final int lastPositionSeconds;
  final bool completed;

  LessonProgressRequest({
    required this.watchTimeSeconds,
    required this.lastPositionSeconds,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'watch_time_seconds': watchTimeSeconds,
      'last_position_seconds': lastPositionSeconds,
      'completed': completed,
    };
  }
}