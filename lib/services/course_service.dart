import 'dart:convert';
import '../models/lesson_models.dart';
import 'api_service.dart';
import '../models/course_models.dart';

class CourseService {
  // Get all public courses
  static Future<List<Course>> getPublicCourses() async {
    try {
      final response = await ApiService.get('/public/courses');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final courses = (data['courses'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
        return courses;
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Error fetching public courses: $e');
    }
  }

  // Get featured courses (fallback to top enrolled if endpoint returns empty)
  static Future<List<Course>> getFeaturedCourses() async {
    try {
      final response = await ApiService.get('/public/courses/featured');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final courses = (data['courses'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
        
        if (courses.isEmpty) {
          final allCourses = await getPublicCourses();
          allCourses.sort((a, b) => b.totalEnrollments.compareTo(a.totalEnrollments));
          return allCourses.take(5).toList();
        }
        
        return courses;
      } else {
        final allCourses = await getPublicCourses();
        allCourses.sort((a, b) => b.totalEnrollments.compareTo(a.totalEnrollments));
        return allCourses.take(5).toList();
      }
    } catch (e) {
      try {
        final allCourses = await getPublicCourses();
        allCourses.sort((a, b) => b.totalEnrollments.compareTo(a.totalEnrollments));
        return allCourses.take(5).toList();
      } catch (e) {
        throw Exception('Error fetching featured courses: $e');
      }
    }
  }

  // Get dashboard data
  static Future<DashboardData> getDashboardData(String token) async {
    try {
      print('🔍 Fetching dashboard with token: ${token.substring(0, 10)}...');
      final response = await ApiService.get('/user/dashboard', token: token);
      
      print('📡 Dashboard response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardData.fromJson(data);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Dashboard error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching dashboard data: $e');
    }
  }

  // Get enrolled courses
  static Future<List<Course>> getEnrolledCourses(String? token) async {
    try {
      if (token == null) {
        print('⚠️ No token provided for enrolled courses');
        return [];
      }

      print('🔍 Fetching enrolled courses from /user/courses');
      final response = await ApiService.get('/user/courses', token: token);
      
      print('📡 Enrolled courses response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final courses = (data['courses'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
        
        print('✅ Found ${courses.length} enrolled courses');
        return courses;
      } else {
        print('⚠️ Failed to fetch enrolled courses: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching enrolled courses: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get recommended courses
  static Future<List<Course>> getRecommendedCourses(String? token) async {
    try {
      if (token != null) {
        final dashboardData = await getDashboardData(token);
        return dashboardData.recommendedCourses;
      } else {
        final allCourses = await getPublicCourses();
        allCourses.shuffle();
        return allCourses.take(6).toList();
      }
    } catch (e) {
      try {
        final allCourses = await getPublicCourses();
        allCourses.shuffle();
        return allCourses.take(6).toList();
      } catch (e) {
        return [];
      }
    }
  }

  // Get course details with modules and lessons
  static Future<CourseDetail> getCourseDetails(int courseId, String? token) async {
    try {
      final endpoint = token != null 
          ? '/courses/$courseId' 
          : '/public/courses/$courseId';
      
      print('🔍 Fetching course details from $endpoint');
      final response = await ApiService.get(endpoint, token: token);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CourseDetail.fromJson(data);
      } else {
        throw Exception('Failed to load course details');
      }
    } catch (e) {
      throw Exception('Error fetching course details: $e');
    }
  }

  // Get user profile
  static Future<UserProfile> getUserProfile(String token) async {
    try {
      final dashboardData = await getDashboardData(token);
      return dashboardData.userInfo;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

static Future<bool> enrollInCourse(int courseId, String token) async {
  try {
    print('🔵 Starting enrollment for course ID: $courseId');

    final response = await ApiService.post(
      '/courses/$courseId/enroll',
      body: {}, // no body needed unless backend requires it
      token: token,
    );

    print('📡 Enroll response status: ${response.statusCode}');
    print('📡 Enroll response body: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e, stackTrace) {
    print('❌ Enrollment error: $e');
    print('Stack trace: $stackTrace');
    return false;
  }
}

static Future<bool> checkEnrollmentStatus(int courseId, String token) async {
  try {
    final response = await ApiService.get(
      '/courses/$courseId/enrollment',
      token: token,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_enrolled'] == true;
    }

    return false;
  } catch (e) {
    print('❌ Error checking enrollment status: $e');
    return false;
  }
}


  // ==================== LESSON METHODS ====================

  // Update lesson progress
  static Future<bool> updateLessonProgress({
    required int lessonId,
    required String token,
    required int watchTimeSeconds,
    required int lastPositionSeconds,
    required bool completed,
  }) async {
    try {
      final response = await ApiService.post(
        '/lessons/$lessonId/progress',
        body: {
          'watch_time_seconds': watchTimeSeconds,
          'last_position_seconds': lastPositionSeconds,
          'completed': completed,
        },
        token: token,
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error updating lesson progress: $e');
      return false;
    }
  }
static Future<CourseReviewsData> getCourseReviews(int courseId, {String? token}) async {
  try {
    print('🔍 Fetching course reviews from /courses/$courseId/reviews');
    final response = await ApiService.get(
      '/courses/$courseId/reviews',
      token: token, // Pass the token if available
    );
    
    print('📡 Course reviews response status: ${response.statusCode}');
    print('📡 Course reviews response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CourseReviewsData.fromJson(data);
    } else if (response.statusCode == 404) {
      // Course has no reviews yet
      print('⚠️ No reviews found for course $courseId');
      return CourseReviewsData(
        reviews: [],
        totalReviews: 0,
        averageRating: 0.0,
      );
    } else {
      print('⚠️ Failed to load course reviews: ${response.statusCode}');
      return CourseReviewsData(
        reviews: [],
        totalReviews: 0,
        averageRating: 0.0,
      );
    }
  } catch (e, stackTrace) {
    print('❌ Error fetching course reviews: $e');
    print('Stack trace: $stackTrace');
    // Return empty reviews data on error instead of throwing
    return CourseReviewsData(
      reviews: [],
      totalReviews: 0,
      averageRating: 0.0,
    );
  }
}
  // Mark lesson as completed
  static Future<bool> markLessonCompleted({
    required int lessonId,
    required String token,
  }) async {
    try {
      final response = await ApiService.post(
        '/lessons/$lessonId/mark-completed',
        body: {}, // Empty body - adjust if your API requires specific fields
        token: token,
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error marking lesson completed: $e');
      return false;
    }
  }
}

