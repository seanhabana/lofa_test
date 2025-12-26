import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../temporary/course_repository.dart';

// ==================== MODEL CLASSES ====================

class Course {
  final String id;
  final String title;
  final String description;
  final String durationHours;
  final int totalLessons;
  final int completedLessons;
  final double progress;
  final double price;
  final double rating;
  final String plan; // 'free', 'core', 'pro', 'elite'
  final String imageUrl;
  final String category;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.durationHours,
    required this.totalLessons,
    required this.completedLessons,
    required this.progress,
    required this.price,
    required this.rating,
    required this.plan,
    required this.imageUrl,
    required this.category,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String subscriptionPlan;
  final bool isPremium;

  UserProfile({
    required this.name,
    required this.email,
    required this.subscriptionPlan,
    required this.isPremium,
  });
}

class Lesson {
  final String id;
  final int lessonNumber;
  final String title;
  final String description;
  final String content;
  final String videoUrl;
  final int durationMinutes;
  final bool isFree;
  final bool isCompleted;
  final String plan; // 'free', 'core', 'pro', 'elite'

  Lesson({
    required this.id,
    required this.lessonNumber,
    required this.title,
    required this.description,
    required this.content,
    required this.videoUrl,
    required this.durationMinutes,
    required this.isFree,
    required this.isCompleted,
    required this.plan,
  });
}

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

class CourseDetail {
  final Course course;
  final List<Lesson> lessons;
  final int completedLessons;
  final double progress;

  CourseDetail({
    required this.course,
    required this.lessons,
    required this.completedLessons,
    required this.progress,
  });
}

// ==================== HOME VIEW MODEL ====================

class HomeViewModel extends StateNotifier<AsyncValue<HomeState>> {
  HomeViewModel() : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final homeState = HomeState(
        user: UserProfile(
          name: 'John Doe',
          email: 'john@example.com',
          subscriptionPlan: 'Pro Plan Member',
          isPremium: true,
        ),
        featuredCourses: CourseRepository.getFeaturedCourses(),
        enrolledCourses: CourseRepository.getEnrolledCourses(),
        recommendedCourses: CourseRepository.getRecommendedCourses(),
      );

      state = AsyncValue.data(homeState);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, AsyncValue<HomeState>>((ref) {
  return HomeViewModel();
});

// ==================== COURSES VIEW MODEL ====================

class CoursesViewModel extends StateNotifier<AsyncValue<CoursesState>> {
  CoursesViewModel() : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final coursesState = CoursesState(
        latestCourses: CourseRepository.getLatestCourses(),
        freeCourses: CourseRepository.getFreeCourses(),
        corePlanCourses: CourseRepository.getCoursesByPlan('core'),
        proPlanCourses: CourseRepository.getCoursesByPlan('pro'),
        elitePlanCourses: CourseRepository.getCoursesByPlan('elite'),
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
    FutureProvider.family<CourseDetail, String>((ref, courseId) async {
  await Future.delayed(const Duration(milliseconds: 500));

  final course = CourseRepository.getCourseById(courseId);
  if (course == null) {
    throw Exception('Course not found');
  }

  final lessons = CourseRepository.getLessonsForCourse(courseId);

  return CourseDetail(
    course: course,
    lessons: lessons,
    completedLessons: course.completedLessons,
    progress: course.progress,
  );
});

// ==================== LESSON DETAIL PROVIDER ====================

final lessonDetailProvider =
    FutureProvider.family<Lesson, String>((ref, lessonId) async {
  await Future.delayed(const Duration(milliseconds: 300));

  // Extract courseId from lessonId (format: courseId_lesson_number)
  final parts = lessonId.split('_lesson_');
  if (parts.length != 2) {
    throw Exception('Invalid lesson ID format');
  }

  final courseId = parts[0];
  final lessons = CourseRepository.getLessonsForCourse(courseId);

  try {
    return lessons.firstWhere((l) => l.id == lessonId);
  } catch (e) {
    throw Exception('Lesson not found');
  }
});