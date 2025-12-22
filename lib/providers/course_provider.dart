import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String imageUrl;

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
    required this.imageUrl,
  });
}

class UserProfile {
  final String name;
  final String subscriptionPlan;
  final bool isPremium;

  UserProfile({
    required this.name,
    required this.subscriptionPlan,
    required this.isPremium,
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

class HomeViewModel extends StateNotifier<AsyncValue<HomeState>> {
  HomeViewModel() : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final homeState = HomeState(
        user: UserProfile(
          name: 'John Doe',
          subscriptionPlan: 'Premium Plan',
          isPremium: true,
        ),
        featuredCourses: _getDummyFeaturedCourses(),
        enrolledCourses: _getDummyEnrolledCourses(),
        recommendedCourses: _getDummyRecommendedCourses(),
      );
      
      state = AsyncValue.data(homeState);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<Course> _getDummyFeaturedCourses() {
  return [
    Course(
      id: '1',
      title: 'Advanced Flutter Development with Clean Architecture',
      description:
          'Master Flutter using clean architecture, Riverpod, MVVM, animations, performance optimization, and real-world scalable project patterns.',
      durationHours: '14 hrs',
      totalLessons: 52,
      completedLessons: 18,
      progress: 0.35,
      price: 3250,
      rating: 4.8,
      imageUrl: '',
    ),
    Course(
      id: '2',
      title: 'UI/UX Design Fundamentals for Mobile and Web Applications',
      description:
          'Learn core UI and UX principles, typography, color theory, spacing systems, and how to design modern, user-friendly interfaces.',
      durationHours: '9 hrs',
      totalLessons: 34,
      completedLessons: 0,
      progress: 0.0,
      price: 2500,
      rating: 4.9,
      imageUrl: '',
    ),
    Course(
      id: '3',
      title: 'State Management in Flutter: Provider, Riverpod, Bloc',
      description:
          'A deep dive into Flutter state management approaches with practical comparisons, use cases, and architecture decisions.',
      durationHours: '11 hrs',
      totalLessons: 40,
      completedLessons: 6,
      progress: 0.15,
      price: 2900,
      rating: 4.7,
      imageUrl: '',
    ),
  ];
}


  List<Course> _getDummyEnrolledCourses() {
  return [
    Course(
      id: '4',
      title: 'React Native Basics for Cross-Platform Mobile Apps',
      description:
          'Build cross-platform mobile apps using React Native and modern JavaScript.',
      durationHours: '10 hrs',
      totalLessons: 25,
      completedLessons: 8,
      progress: 0.32,
      price: 2800,
      rating: 4.6,
      imageUrl: '',
    ),
    Course(
      id: '5',
      title: 'Firebase Integration: Auth, Firestore, Storage, Functions',
      description:
          'Learn how to integrate Firebase services into your mobile apps efficiently.',
      durationHours: '6 hrs',
      totalLessons: 20,
      completedLessons: 14,
      progress: 0.7,
      price: 1800,
      rating: 4.7,
      imageUrl: '',
    ),
    Course(
      id: '6',
      title: 'Git & GitHub Essentials for Developers',
      description:
          'Version control basics, branching strategies, pull requests, and collaboration.',
      durationHours: '5 hrs',
      totalLessons: 18,
      completedLessons: 18,
      progress: 1.0,
      price: 1500,
      rating: 4.9,
      imageUrl: '',
    ),
  ];
}


  List<Course> _getDummyRecommendedCourses() {
  return [
    Course(
      id: '7',
      title: 'Python for Data Science and Machine Learning',
      description:
          'Analyze data, build machine learning models, and visualize insights using Python libraries.',
      durationHours: '16 hrs',
      totalLessons: 55,
      completedLessons: 0,
      progress: 0.0,
      price: 3250,
      rating: 4.8,
      imageUrl: '',
    ),
    Course(
      id: '8',
      title: 'Full-Stack Web Development Bootcamp',
      description:
          'Learn HTML, CSS, JavaScript, backend APIs, databases, and deployment.',
      durationHours: '22 hrs',
      totalLessons: 65,
      completedLessons: 0,
      progress: 0.0,
      price: 1200,
      rating: 4.5,
      imageUrl: '',
    ),
    Course(
      id: '9',
      title: 'Kotlin for Android Development',
      description:
          'Build modern Android apps using Kotlin, Jetpack components, and best practices.',
      durationHours: '12 hrs',
      totalLessons: 38,
      completedLessons: 0,
      progress: 0.0,
      price: 2700,
      rating: 4.6,
      imageUrl: '',
    ),
  ];
}

}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, AsyncValue<HomeState>>((ref) {
  return HomeViewModel();
});
