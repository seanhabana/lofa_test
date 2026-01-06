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
  
  // ✅ NEW: Video duration in seconds (from backend or null if not available)
  final int? videoDurationSeconds;

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
    this.videoDurationSeconds, // ✅ NEW: Optional field
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
      
      // ✅ NEW: Parse video_duration_seconds from backend (if available)
      videoDurationSeconds: json['video_duration_seconds'] as int?,
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
  
  // ✅ NEW: Helper to get estimated duration in seconds
  // Falls back to durationMinutes * 60 if videoDurationSeconds is not available
  int get estimatedDurationSeconds {
    return videoDurationSeconds ?? (durationMinutes * 60);
  }
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

// ✅ NEW: Lesson completion request model (matches Laravel API from document 4)
class LessonCompletionRequest {
  final int watchedDuration;
  final int totalDuration;
  final DateTime completedAt;
  final LessonCompletionVerification? verification;

  LessonCompletionRequest({
    required this.watchedDuration,
    required this.totalDuration,
    required this.completedAt,
    this.verification,
  });

  Map<String, dynamic> toJson() {
    return {
      'watched_duration': watchedDuration,
      'total_duration': totalDuration,
      'completed_at': completedAt.toIso8601String(),
      if (verification != null) 'verification': verification!.toJson(),
    };
  }
}

// ✅ NEW: Verification data for lesson completion
class LessonCompletionVerification {
  final int watchTime;
  final int duration;
  final int timestamp;

  LessonCompletionVerification({
    required this.watchTime,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'watch_time': watchTime,
      'duration': duration,
      'timestamp': timestamp,
    };
  }
}

// ✅ NEW: Lesson completion response model
class LessonCompletionResponse {
  final String message;
  final LessonProgress progress;
  final CourseEnrollmentInfo enrollment;
  final bool courseCompleted;
  final bool certificateGenerated;
  final Certificate? certificate;
  final bool alreadyCompleted;

  LessonCompletionResponse({
    required this.message,
    required this.progress,
    required this.enrollment,
    required this.courseCompleted,
    required this.certificateGenerated,
    this.certificate,
    this.alreadyCompleted = false,
  });

  factory LessonCompletionResponse.fromJson(Map<String, dynamic> json) {
    return LessonCompletionResponse(
      message: json['message'] ?? '',
      progress: LessonProgress.fromJson(json['progress'] ?? {}),
      enrollment: CourseEnrollmentInfo.fromJson(json['enrollment'] ?? {}),
      courseCompleted: json['course_completed'] ?? false,
      certificateGenerated: json['certificate_generated'] ?? false,
      certificate: json['certificate'] != null 
          ? Certificate.fromJson(json['certificate']) 
          : null,
      alreadyCompleted: json['already_completed'] ?? false,
    );
  }
}

// ✅ NEW: Lesson progress model (from completion response)
class LessonProgress {
  final int id;
  final int userId;
  final int courseEnrollmentId;
  final int courseLessonId;
  final String status;
  final int progressPercent;
  final DateTime? completedAt;
  final int timeSpentSeconds;
  final DateTime? lastAccessedAt;

  LessonProgress({
    required this.id,
    required this.userId,
    required this.courseEnrollmentId,
    required this.courseLessonId,
    required this.status,
    required this.progressPercent,
    this.completedAt,
    required this.timeSpentSeconds,
    this.lastAccessedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseEnrollmentId: json['course_enrollment_id'] ?? 0,
      courseLessonId: json['course_lesson_id'] ?? 0,
      status: json['status'] ?? 'not_started',
      progressPercent: json['progress_percent'] ?? 0,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      timeSpentSeconds: json['time_spent_seconds'] ?? 0,
      lastAccessedAt: json['last_accessed_at'] != null 
          ? DateTime.parse(json['last_accessed_at']) 
          : null,
    );
  }
}

// ✅ NEW: Course enrollment info model
class CourseEnrollmentInfo {
  final int id;
  final int userId;
  final int courseId;
  final int progressPercentage;
  final DateTime enrolledAt;
  final DateTime? completedAt;

  CourseEnrollmentInfo({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.progressPercentage,
    required this.enrolledAt,
    this.completedAt,
  });

  factory CourseEnrollmentInfo.fromJson(Map<String, dynamic> json) {
    return CourseEnrollmentInfo(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      progressPercentage: json['progress_percentage'] ?? 0,
      enrolledAt: json['enrolled_at'] != null 
          ? DateTime.parse(json['enrolled_at']) 
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
}

// ✅ NEW: Certificate model
class Certificate {
  final int id;
  final int userId;
  final int courseId;
  final String certificateNumber;
  final String certificateFilePath;
  final DateTime issuedAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.certificateNumber,
    required this.certificateFilePath,
    required this.issuedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      certificateNumber: json['certificate_number'] ?? '',
      certificateFilePath: json['certificate_file_path'] ?? '',
      issuedAt: json['issued_at'] != null 
          ? DateTime.parse(json['issued_at']) 
          : DateTime.now(),
    );
  }
  
  // Helper to get full certificate URL
  String getCertificateUrl(String baseUrl) {
    return '$baseUrl/storage/$certificateFilePath';
  }
}