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
  final String plan; // 'free', 'core', 'pro', 'elite'
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
    required this.plan,
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

class Lesson {
  final String id;
  final String courseId;
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
    required this.courseId,
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
        plan: 'pro',
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
        plan: 'core',
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
        plan: 'core',
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
        plan: 'core',
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
        plan: 'pro',
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
        plan: 'free',
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
        plan: 'pro',
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
        plan: 'core',
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
        plan: 'core',
        rating: 4.6,
        imageUrl: '',
      ),
    ];
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, AsyncValue<HomeState>>((ref) {
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
        latestCourses: _getLatestCourses(),
        freeCourses: _getFreeCourses(),
        corePlanCourses: _getCorePlanCourses(),
        proPlanCourses: _getProPlanCourses(),
        elitePlanCourses: _getElitePlanCourses(),
      );
      
      state = AsyncValue.data(coursesState);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<Course> _getLatestCourses() {
    return [
      Course(
        id: 'latest1',
        title: 'Modern Web Development with Next.js 14',
        description: 'Build full-stack applications with the latest Next.js features including server components and app router.',
        durationHours: '18 hrs',
        totalLessons: 65,
        completedLessons: 0,
        progress: 0.0,
        price: 3500,
        plan: 'pro',
        rating: 4.9,
        imageUrl: '',
      ),
      Course(
        id: 'latest2',
        title: 'AI and Machine Learning Fundamentals',
        description: 'Introduction to artificial intelligence, neural networks, and practical ML applications.',
        durationHours: '20 hrs',
        totalLessons: 72,
        completedLessons: 0,
        progress: 0.0,
        price: 4200,
        plan: 'pro',
        rating: 4.8,
        imageUrl: '',
      ),
      Course(
        id: 'latest3',
        title: 'Cybersecurity Essentials for Developers',
        description: 'Learn security best practices, encryption, authentication, and how to protect applications.',
        durationHours: '12 hrs',
        totalLessons: 45,
        completedLessons: 0,
        progress: 0.0,
        price: 3000,
        plan: 'core',
        rating: 4.7,
        imageUrl: '',
      ),
    ];
  }

  List<Course> _getFreeCourses() {
    return [
      Course(
        id: 'free1',
        title: 'Introduction to Programming',
        description: 'Start your coding journey with basic programming concepts and problem-solving.',
        durationHours: '8 hrs',
        totalLessons: 30,
        completedLessons: 0,
        progress: 0.0,
        price: 0,
        plan: 'free',
        rating: 4.5,
        imageUrl: '',
      ),
      Course(
        id: 'free2',
        title: 'Git Version Control Basics',
        description: 'Master the fundamentals of Git for tracking code changes and collaborating.',
        durationHours: '4 hrs',
        totalLessons: 15,
        completedLessons: 0,
        progress: 0.0,
        price: 0,
        plan: 'free',
        rating: 4.6,
        imageUrl: '',
      ),
      Course(
        id: 'free3',
        title: 'HTML & CSS Crash Course',
        description: 'Build beautiful websites from scratch using HTML5 and CSS3.',
        durationHours: '6 hrs',
        totalLessons: 25,
        completedLessons: 0,
        progress: 0.0,
        price: 0,
        plan: 'free',
        rating: 4.7,
        imageUrl: '',
      ),
    ];
  }

  List<Course> _getCorePlanCourses() {
    return [
      Course(
        id: 'core1',
        title: 'JavaScript Fundamentals',
        description: 'Master JavaScript from basics to advanced concepts including ES6+ features.',
        durationHours: '15 hrs',
        totalLessons: 55,
        completedLessons: 0,
        progress: 0.0,
        price: 2200,
        plan: 'core',
        rating: 4.7,
        imageUrl: '',
      ),
      Course(
        id: 'core2',
        title: 'React.js Complete Guide',
        description: 'Build modern web applications with React, hooks, context, and state management.',
        durationHours: '16 hrs',
        totalLessons: 60,
        completedLessons: 0,
        progress: 0.0,
        price: 2500,
        plan: 'core',
        rating: 4.8,
        imageUrl: '',
      ),
      Course(
        id: 'core3',
        title: 'Node.js Backend Development',
        description: 'Create scalable backend APIs with Node.js, Express, and MongoDB.',
        durationHours: '14 hrs',
        totalLessons: 50,
        completedLessons: 0,
        progress: 0.0,
        price: 2400,
        plan: 'core',
        rating: 4.6,
        imageUrl: '',
      ),
    ];
  }

  List<Course> _getProPlanCourses() {
    return [
      Course(
        id: 'pro1',
        title: 'Advanced Flutter & Dart Mastery',
        description: 'Deep dive into Flutter animations, custom widgets, and performance optimization.',
        durationHours: '22 hrs',
        totalLessons: 85,
        completedLessons: 0,
        progress: 0.0,
        price: 3800,
        plan: 'pro',
        rating: 4.9,
        imageUrl: '',
      ),
      Course(
        id: 'pro2',
        title: 'AWS Cloud Architecture',
        description: 'Design and deploy scalable cloud solutions using AWS services and best practices.',
        durationHours: '20 hrs',
        totalLessons: 75,
        completedLessons: 0,
        progress: 0.0,
        price: 4000,
        plan: 'pro',
        rating: 4.8,
        imageUrl: '',
      ),
      Course(
        id: 'pro3',
        title: 'Microservices with Docker & Kubernetes',
        description: 'Build, containerize, and orchestrate microservices architecture.',
        durationHours: '18 hrs',
        totalLessons: 68,
        completedLessons: 0,
        progress: 0.0,
        price: 3600,
        plan: 'pro',
        rating: 4.7,
        imageUrl: '',
      ),
    ];
  }

  List<Course> _getElitePlanCourses() {
    return [
      Course(
        id: 'elite1',
        title: 'System Design & Architecture Masterclass',
        description: 'Design large-scale distributed systems with real-world case studies and patterns.',
        durationHours: '25 hrs',
        totalLessons: 95,
        completedLessons: 0,
        progress: 0.0,
        price: 5500,
        plan: 'elite',
        rating: 5.0,
        imageUrl: '',
      ),
      Course(
        id: 'elite2',
        title: 'Advanced Data Structures & Algorithms',
        description: 'Master complex algorithms and data structures for technical interviews and optimization.',
        durationHours: '30 hrs',
        totalLessons: 110,
        completedLessons: 0,
        progress: 0.0,
        price: 6000,
        plan: 'elite',
        rating: 4.9,
        imageUrl: '',
      ),
      Course(
        id: 'elite3',
        title: 'Full-Stack Blockchain Development',
        description: 'Build decentralized applications with Solidity, Web3.js, and smart contracts.',
        durationHours: '28 hrs',
        totalLessons: 100,
        completedLessons: 0,
        progress: 0.0,
        price: 5800,
        plan: 'elite',
        rating: 4.8,
        imageUrl: '',
      ),
    ];
  }
}

final coursesViewModelProvider = StateNotifierProvider<CoursesViewModel, AsyncValue<CoursesState>>((ref) {
  return CoursesViewModel();
});

// ==================== COURSE DETAIL VIEW MODEL ====================

class CourseDetailViewModel extends StateNotifier<AsyncValue<CourseDetail>> {
  final String courseId;

  CourseDetailViewModel(this.courseId) : super(const AsyncValue.loading()) {
    loadCourseDetail();
  }

  Future<void> loadCourseDetail() async {
    state = const AsyncValue.loading();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final courseDetail = CourseDetail(
        course: _getCourseById(courseId),
        lessons: _getLessonsForCourse(courseId),
        completedLessons: 0,
        progress: 0.0,
      );
      
      state = AsyncValue.data(courseDetail);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Course _getCourseById(String id) {
    return Course(
      id: id,
      title: 'Advanced Flutter Development',
      description: 'Master Flutter using clean architecture, Riverpod, MVVM, and more.',
      durationHours: '14 hrs',
      totalLessons: 3,
      completedLessons: 0,
      progress: 50.0,
      price: 3250,
      rating: 4.8,
                              plan: 'elite',

      imageUrl: '',
    );
  }

  List<Lesson> _getLessonsForCourse(String courseId) {
    return [
      Lesson(
        id: 'lesson1',
        courseId: courseId,
        lessonNumber: 1,
        title: 'Introduction to Java',
        description: 'Tackles the history of Java',
        content: 'Student will learn Java basics and fundamentals.',
        videoUrl: 'https://www.youtube.com/watch?v=Hiy2_Azjp0g',
        durationMinutes: 10,
        isFree: true,
        isCompleted: false,
        plan: 'free',
      ),
      Lesson(
        id: 'lesson2',
        courseId: courseId,
        lessonNumber: 2,
        title: 'Fundamentals of Java',
        description: 'F-experimental',
        content: 'Deep dive into Java syntax and data types.',
        videoUrl: 'https://www.youtube.com/watch?v=Hiy2_Azjp0g',
        durationMinutes: 15,
        isFree: false,
        isCompleted: false,
        plan: 'core',
      ),
      Lesson(
        id: 'lesson3',
        courseId: courseId,
        lessonNumber: 3,
        title: 'Classes and Objects',
        description: 'Classic and Object in Java',
        content: 'Understanding OOP concepts in Java.',
        videoUrl: 'https://www.youtube.com/watch?v=Hiy2_Azjp0g',
        durationMinutes: 18,
        isFree: false,
        isCompleted: false,
        plan: 'pro',
      ),
    ];
  }

  void markLessonCompleted(String lessonId) {
    // Update lesson completion status
  }
}

final courseDetailProvider = StateNotifierProvider.family<CourseDetailViewModel, AsyncValue<CourseDetail>, String>(
  (ref, courseId) => CourseDetailViewModel(courseId),
);

// ==================== LESSON DETAIL VIEW MODEL ====================

class LessonDetailViewModel extends StateNotifier<AsyncValue<Lesson>> {
  final String lessonId;

  LessonDetailViewModel(this.lessonId) : super(const AsyncValue.loading()) {
    loadLesson();
  }

  Future<void> loadLesson() async {
    state = const AsyncValue.loading();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final lesson = Lesson(
        id: lessonId,
        courseId: 'course1',
        lessonNumber: 1,
        title: 'Introduction to Java',
        description: 'Tackles the history of Java',
        content: 'Student will learn Java basics and fundamentals.',
        videoUrl: 'https://example.com/video1.mp4',
        durationMinutes: 10,
        isFree: true,
        isCompleted: false,
        plan: 'free',
      );
      
      state = AsyncValue.data(lesson);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final lessonDetailProvider = StateNotifierProvider.family<LessonDetailViewModel, AsyncValue<Lesson>, String>(
  (ref, lessonId) => LessonDetailViewModel(lessonId),
);