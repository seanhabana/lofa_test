// Course Models
// Course Model - Updated to support modules

import 'package:lofa_test/models/lesson_models.dart';

class Course {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String shortDescription;
  final String thumbnail;
  final String difficultyLevel;
  final int estimatedDurationMinutes;
  final bool isFeatured;
  final String? category;
  final Instructor instructor;
  final String averageRating;
  final int totalReviews;
  final int totalEnrollments;
  final int lessonsCount;
  final int modulesCount;
  final int? requiredPlanId;
  final String requiredPlanName;
  final String requiredPlanDisplayName;
  final int requiredSubscriptionTier;
  final String language;
  final CourseProgress? progress;
  final String? enrollmentDate;
  final List<CourseModule>? modules; // NEW: Optional modules
  final String createdAt;
  final String updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.shortDescription,
    required this.thumbnail,
    required this.difficultyLevel,
    required this.estimatedDurationMinutes,
    required this.isFeatured,
    this.category,
    required this.instructor,
    required this.averageRating,
    required this.totalReviews,
    required this.totalEnrollments,
    required this.lessonsCount,
    required this.modulesCount,
    this.requiredPlanId,
    required this.requiredPlanName,
    required this.requiredPlanDisplayName,
    required this.requiredSubscriptionTier,
    required this.language,
    this.progress,
    this.enrollmentDate,
    this.modules,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 'basic',
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      category: json['category'],
      instructor: Instructor.fromJson(json['instructor'] ?? {}),
      averageRating: json['average_rating']?.toString() ?? '0.0',
      totalReviews: json['total_reviews'] ?? 0,
      totalEnrollments: json['total_enrollments'] ?? 0,
      lessonsCount: json['lessons_count'] ?? 0,
      modulesCount: json['modules_count'] ?? 0,
      requiredPlanId: json['required_plan_id'],
      requiredPlanName: json['required_plan_name'] ?? 'free',
      requiredPlanDisplayName: json['required_plan_display_name'] ?? 'Free',
      requiredSubscriptionTier: json['required_subscription_tier'] ?? 0,
      language: json['language'] ?? 'English',
      progress: json['progress'] != null 
          ? CourseProgress.fromJson(json['progress']) 
          : null,
      enrollmentDate: json['enrollment_date'],
      modules: json['modules'] != null
          ? (json['modules'] as List)
              .map((m) => CourseModule.fromJson(m))
              .toList()
          : null,
      createdAt: json['created_at'] ?? json['last_updated_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Helper getters for UI
  String get durationHours {
    final hours = estimatedDurationMinutes / 60;
    if (hours < 1) {
      return '$estimatedDurationMinutes min';
    } else if (hours % 1 == 0) {
      return '${hours.toInt()} hrs';
    } else {
      return '${hours.toStringAsFixed(1)} hrs';
    }
  }

  double get rating => double.tryParse(averageRating) ?? 0.0;

  int get completedLessons => progress?.completedLessons ?? 0;

  double get progressPercentage => progress?.percentage.toDouble() ?? 0.0;

  String get plan => requiredPlanName;

  String get imageUrl {
    const baseUrl = 'https://staging.api.lofaconsulting.com.au';
    return '$baseUrl$thumbnail';
  }

  // NEW: Get total lessons from modules if available
  int get totalLessons {
    if (modules != null) {
      return modules!.fold(0, (sum, module) => sum + module.lessons.length);
    }
    return lessonsCount;
  }
}


class Instructor {
  final int id;
  final String name;

  Instructor({
    required this.id,
    required this.name,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
    );
  }
}

class CourseProgress {
  final int totalLessons;
  final int completedLessons;
  final int percentage;
  final String? lastActivity;

  CourseProgress({
    required this.totalLessons,
    required this.completedLessons,
    required this.percentage,
    this.lastActivity,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      totalLessons: json['total_lessons'],
      completedLessons: json['completed_lessons'],
      percentage: json['percentage'],
      lastActivity: json['last_activity'],
    );
  }
}

// User Models

class UserProfile {
  final String name;
  final String email;
  final String joinedDate;
  final UserSubscription subscription;
  final int unviewedCertificatesCount;

  UserProfile({
    required this.name,
    required this.email,
    required this.joinedDate,
    required this.subscription,
    required this.unviewedCertificatesCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      joinedDate: json['joined_date'] ?? '',
      subscription: UserSubscription.fromJson(json['subscription'] ?? {}),
      unviewedCertificatesCount: json['unviewed_certificates_count'] ?? 0,
    );
  }

  String get subscriptionPlan => subscription.displayName;
  bool get isPremium => subscription.tier > 0;
}

class UserSubscription {
  final String planName;
  final String displayName;
  final String status;
  final String? expiresAt;

  UserSubscription({
    required this.planName,
    required this.displayName,
    required this.status,
    this.expiresAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      planName: json['plan_name'] ?? 'free',
      displayName: json['display_name'] ?? 'Free Access',
      status: json['status'] ?? 'active',
      expiresAt: json['expires_at'],
    );
  }

  int get tier {
    switch (planName.toLowerCase()) {
      case 'free':
        return 0;
      case 'core':
        return 1;
      case 'pro':
        return 2;
      case 'elite':
        return 3;
      default:
        return 0;
    }
  }
}
// Dashboard Models

class DashboardStats {
  final int totalEnrolledCourses;
  final int totalCompletedCourses;
  final int totalHoursStudied;
  final int averageProgress;
  final int totalCertificates;
  final int unviewedCertificates;

  DashboardStats({
    required this.totalEnrolledCourses,
    required this.totalCompletedCourses,
    required this.totalHoursStudied,
    required this.averageProgress,
    required this.totalCertificates,
    required this.unviewedCertificates,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int _toInt(dynamic value, String fieldName) {
      if (value == null) {
        print('⚠️ DashboardStats: $fieldName is null, defaulting to 0');
        return 0;
      }
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        print('⚠️ DashboardStats: Could not parse $fieldName "$value", defaulting to 0');
        return 0;
      }
      print('⚠️ DashboardStats: Unexpected type for $fieldName: ${value.runtimeType}, defaulting to 0');
      return 0;
    }

    try {
      print('📊 Parsing DashboardStats from JSON:');
      print('   Raw JSON: $json');
      
      final stats = DashboardStats(
        totalEnrolledCourses: _toInt(json['total_enrolled_courses'], 'total_enrolled_courses'),
        totalCompletedCourses: _toInt(json['total_completed_courses'], 'total_completed_courses'),
        totalHoursStudied: _toInt(json['total_hours_studied'], 'total_hours_studied'),
        averageProgress: _toInt(json['average_progress'], 'average_progress'),
        totalCertificates: _toInt(json['total_certificates'], 'total_certificates'),
        unviewedCertificates: _toInt(json['unviewed_certificates'], 'unviewed_certificates'),
      );
      
      print('✅ DashboardStats parsed successfully');
      return stats;
    } catch (e, stack) {
      print('❌ Error parsing DashboardStats: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}

class DashboardData {
  final List<Course> enrolledCourses;
  final DashboardStats stats;
  final List<dynamic> recentActivity;
  final List<dynamic> certificates;
  final List<Course> recommendedCourses;
  final UserProfile userInfo;

  DashboardData({
    required this.enrolledCourses,
    required this.stats,
    required this.recentActivity,
    required this.certificates,
    required this.recommendedCourses,
    required this.userInfo,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    try {
      print('📦 Parsing DashboardData from JSON');
      print('   Keys present: ${json.keys.toList()}');
      
      return DashboardData(
        enrolledCourses: (json['enrolledCourses'] as List?)
            ?.map((e) => Course.fromJson(e))
            .toList() ?? [],
        stats: DashboardStats.fromJson(json['stats'] ?? {}),
        recentActivity: json['recentActivity'] as List? ?? [],
        certificates: json['certificates'] as List? ?? [],
        recommendedCourses: (json['recommendedCourses'] as List?)
            ?.map((e) => Course.fromJson(e))
            .toList() ?? [],
        userInfo: UserProfile.fromJson(json['userInfo'] ?? {}),
      );
    } catch (e, stack) {
      print('❌ Error parsing DashboardData: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}

// Add this to course_models.dart

class CourseReview {
  final int id;
  final String userName;
  final int rating;
  final String review;
  final bool isAnonymous;
  final String createdAt;
  final String createdAtHuman;

  CourseReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.review,
    required this.isAnonymous,
    required this.createdAt,
    required this.createdAtHuman,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? 'Anonymous',
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: json['created_at'] ?? '',
      createdAtHuman: json['created_at_human'] ?? '',
    );
  }
}

class CourseReviewsData {
  final List<CourseReview> reviews;
  final int totalReviews;
  final double averageRating;

  CourseReviewsData({
    required this.reviews,
    required this.totalReviews,
    required this.averageRating,
  });

  factory CourseReviewsData.fromJson(Map<String, dynamic> json) {
    return CourseReviewsData(
      reviews: (json['reviews'] as List?)
          ?.map((r) => CourseReview.fromJson(r))
          .toList() ?? [],
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: (json['average_rating'] is int)
          ? (json['average_rating'] as int).toDouble()
          : (json['average_rating'] ?? 0.0),
    );
  }
}