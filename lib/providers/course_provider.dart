import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_models.dart';
import '../models/lesson_models.dart';
import '../services/course_service.dart';
import '../providers/auth_session_provider.dart';

// ==================== STATE CLASSES ====================

class HomeState {
  final UserProfile user;
  final List<Course> featuredCourses;
  final List<Course> enrolledCourses;
  final List<Course> recommendedCourses;

  HomeState({
    required this.user,
    required this.featuredCourses,
    required this.enrolledCourses,
    required this.recommendedCourses,
  });
}

class CoursesState {
  final List<Course> latestCourses;
  final List<Course> freeCourses;
  final List<Course> corePlanCourses;
  final List<Course> proPlanCourses;
  final List<Course> elitePlanCourses;

  CoursesState({
    required this.latestCourses,
    required this.freeCourses,
    required this.corePlanCourses,
    required this.proPlanCourses,
    required this.elitePlanCourses,
  });
}

// ==================== HOME VIEW MODEL ====================

class HomeViewModel extends StateNotifier<AsyncValue<HomeState>> {
  final String? token;
  
  HomeViewModel(this.token) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();

    try {
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final results = await Future.wait([
        CourseService.getUserProfile(token!),
        CourseService.getFeaturedCourses(),
        CourseService.getEnrolledCourses(token),
        CourseService.getRecommendedCourses(token),
      ]);

      final homeState = HomeState(
        user: results[0] as UserProfile,
        featuredCourses: results[1] as List<Course>,
        enrolledCourses: results[2] as List<Course>,
        recommendedCourses: results[3] as List<Course>,
      );

      state = AsyncValue.data(homeState);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, AsyncValue<HomeState>>((ref) {
  final authState = ref.watch(authSessionProvider);
  return HomeViewModel(authState.token);
});

// ==================== COURSES VIEW MODEL ====================

class CoursesViewModel extends StateNotifier<AsyncValue<CoursesState>> {
  CoursesViewModel() : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();

    try {
      final allCourses = await CourseService.getPublicCourses();

      // Sort by created date for latest courses
      final latestCourses = List<Course>.from(allCourses);
      latestCourses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Filter courses by plan
      final freeCourses = allCourses
          .where((c) => c.requiredPlanName.toLowerCase() == 'free')
          .toList();
      final coreCourses = allCourses
          .where((c) => c.requiredPlanName.toLowerCase() == 'core')
          .toList();
      final proCourses = allCourses
          .where((c) => c.requiredPlanName.toLowerCase() == 'pro')
          .toList();
      final eliteCourses = allCourses
          .where((c) => c.requiredPlanName.toLowerCase() == 'elite')
          .toList();

      final coursesState = CoursesState(
        latestCourses: latestCourses.take(10).toList(),
        freeCourses: freeCourses,
        corePlanCourses: coreCourses,
        proPlanCourses: proCourses,
        elitePlanCourses: eliteCourses,
      );

      state = AsyncValue.data(coursesState);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final coursesViewModelProvider =
    StateNotifierProvider<CoursesViewModel, AsyncValue<CoursesState>>((ref) {
  return CoursesViewModel();
});

// ==================== COURSE DETAIL PROVIDER ====================

final courseDetailProvider =
    FutureProvider.family<CourseDetail, int>((ref, courseId) async {
  final authState = ref.watch(authSessionProvider);
  return await CourseService.getCourseDetails(courseId, authState.token);
});

// ==================== ENROLLMENT STATUS PROVIDER ====================

final enrollmentStatusProvider =
    FutureProvider.family<bool, int>((ref, courseId) async {
  final authState = ref.watch(authSessionProvider);
  if (authState.token == null) return false;
  return await CourseService.checkEnrollmentStatus(courseId, authState.token!);
});

// Add this provider

final courseReviewsProvider =
    FutureProvider.family<CourseReviewsData, int>((ref, courseId) async {
  final authState = ref.watch(authSessionProvider);
  return await CourseService.getCourseReviews(courseId, token: authState.token);
});