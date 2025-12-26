// lib/data/course_repository.dart
import '../providers/course_provider.dart';

class CourseRepository {
  static final CourseRepository _instance = CourseRepository._internal();
  factory CourseRepository() => _instance;
  CourseRepository._internal();

  // All courses data - NDIS/Disability Support focused
  static final List<Course> allCourses = [
    // Support Strategies Courses
    Course(
      id: 'course1',
      title: 'Effective Support Strategies Fundamentals',
      description: 'Learn proven techniques for providing quality support to NDIS participants in various settings.',
      durationHours: '8 hrs',
      totalLessons: 32,
      completedLessons: 8,
      progress: 0.25,
      price: 2499,
      plan: 'core',
      rating: 4.8,
      imageUrl: '',
      category: 'support-strategies',
    ),
    Course(
      id: 'course2',
      title: 'Advanced Communication Techniques',
      description: 'Master communication strategies for working with NDIS participants with diverse needs.',
      durationHours: '10 hrs',
      totalLessons: 40,
      completedLessons: 0,
      progress: 0.0,
      price: 3299,
      plan: 'pro',
      rating: 4.9,
      imageUrl: '',
      category: 'communication',
    ),
    Course(
      id: 'course3',
      title: 'Assistive Technology Mastery',
      description: 'Comprehensive guide to assistive technologies and their applications in disability support.',
      durationHours: '12 hrs',
      totalLessons: 48,
      completedLessons: 0,
      progress: 0.0,
      price: 4999,
      plan: 'elite',
      rating: 4.7,
      imageUrl: '',
      category: 'assistive-technology',
    ),
    
    // Free Courses
    Course(
      id: 'free1',
      title: 'Introduction to NDIS',
      description: 'Understanding the National Disability Insurance Scheme and how it works.',
      durationHours: '4 hrs',
      totalLessons: 16,
      completedLessons: 0,
      progress: 0.0,
      price: 0,
      plan: 'free',
      rating: 4.5,
      imageUrl: '',
      category: 'ndis-processes',
    ),
    Course(
      id: 'free2',
      title: 'Disability Awareness Basics',
      description: 'Building foundational understanding of different disability types and support needs.',
      durationHours: '3 hrs',
      totalLessons: 12,
      completedLessons: 0,
      progress: 0.0,
      price: 0,
      plan: 'free',
      rating: 4.6,
      imageUrl: '',
      category: 'support-strategies',
    ),
    Course(
      id: 'free3',
      title: 'Rights and Advocacy Introduction',
      description: 'Understanding the rights of people with disabilities and basic advocacy principles.',
      durationHours: '5 hrs',
      totalLessons: 20,
      completedLessons: 0,
      progress: 0.0,
      price: 0,
      plan: 'free',
      rating: 4.7,
      imageUrl: '',
      category: 'rights-advocacy',
    ),
    
    // Communication Courses
    Course(
      id: 'comm1',
      title: 'Communication Skills for Support Workers',
      description: 'Develop effective communication strategies for diverse participant needs and situations.',
      durationHours: '9 hrs',
      totalLessons: 36,
      completedLessons: 0,
      progress: 0.0,
      price: 2200,
      plan: 'core',
      rating: 4.7,
      imageUrl: '',
      category: 'communication',
    ),
    Course(
      id: 'comm2',
      title: 'Augmentative and Alternative Communication (AAC)',
      description: 'Master AAC systems and strategies to support participants with communication difficulties.',
      durationHours: '11 hrs',
      totalLessons: 44,
      completedLessons: 15,
      progress: 0.34,
      price: 2500,
      plan: 'core',
      rating: 4.8,
      imageUrl: '',
      category: 'communication',
    ),
    
    // Person-Centered Care
    Course(
      id: 'pcc1',
      title: 'Person-Centered Care Fundamentals',
      description: 'Learn to deliver support that respects individual preferences, choices, and goals.',
      durationHours: '10 hrs',
      totalLessons: 40,
      completedLessons: 0,
      progress: 0.0,
      price: 2400,
      plan: 'core',
      rating: 4.6,
      imageUrl: '',
      category: 'person-centered-care',
    ),
    Course(
      id: 'pcc2',
      title: 'Advanced Person-Centered Planning',
      description: 'Deep dive into collaborative planning approaches and goal-setting strategies.',
      durationHours: '13 hrs',
      totalLessons: 52,
      completedLessons: 0,
      progress: 0.0,
      price: 3800,
      plan: 'pro',
      rating: 4.9,
      imageUrl: '',
      category: 'person-centered-care',
    ),
    
    // Daily Living Support
    Course(
      id: 'dls1',
      title: 'Daily Living Support Techniques',
      description: 'Practical strategies for supporting independence in daily activities and routines.',
      durationHours: '8 hrs',
      totalLessons: 32,
      completedLessons: 0,
      progress: 0.0,
      price: 2200,
      plan: 'core',
      rating: 4.5,
      imageUrl: '',
      category: 'daily-living',
    ),
    Course(
      id: 'dls2',
      title: 'Promoting Independence and Skills Development',
      description: 'Advanced methods for building participant capacity and fostering independence.',
      durationHours: '12 hrs',
      totalLessons: 48,
      completedLessons: 0,
      progress: 0.0,
      price: 4000,
      plan: 'pro',
      rating: 4.8,
      imageUrl: '',
      category: 'daily-living',
    ),
    
    // Behavioural Support
    Course(
      id: 'beh1',
      title: 'Understanding Behavioural Support',
      description: 'Evidence-based approaches to understanding and responding to behaviours of concern.',
      durationHours: '14 hrs',
      totalLessons: 56,
      completedLessons: 0,
      progress: 0.0,
      price: 5500,
      plan: 'elite',
      rating: 5.0,
      imageUrl: '',
      category: 'behavioural-support',
    ),
    Course(
      id: 'beh2',
      title: 'Positive Behaviour Support Strategies',
      description: 'Implement positive behaviour support plans and de-escalation techniques.',
      durationHours: '11 hrs',
      totalLessons: 44,
      completedLessons: 0,
      progress: 0.0,
      price: 3500,
      plan: 'pro',
      rating: 4.8,
      imageUrl: '',
      category: 'behavioural-support',
    ),
    
    // Crisis Management
    Course(
      id: 'crisis1',
      title: 'Crisis Prevention and Management',
      description: 'Identify early warning signs and implement effective crisis response strategies.',
      durationHours: '9 hrs',
      totalLessons: 36,
      completedLessons: 0,
      progress: 0.0,
      price: 2800,
      plan: 'core',
      rating: 4.7,
      imageUrl: '',
      category: 'crisis-management',
    ),
    Course(
      id: 'crisis2',
      title: 'Advanced Crisis Response',
      description: 'Master complex crisis situations and trauma-informed support approaches.',
      durationHours: '15 hrs',
      totalLessons: 60,
      completedLessons: 0,
      progress: 0.0,
      price: 6000,
      plan: 'elite',
      rating: 4.9,
      imageUrl: '',
      category: 'crisis-management',
    ),
    
    // Family/Carer Support
    Course(
      id: 'fam1',
      title: 'Supporting Families and Carers',
      description: 'Strategies for working collaboratively with families and informal support networks.',
      durationHours: '7 hrs',
      totalLessons: 28,
      completedLessons: 0,
      progress: 0.0,
      price: 2100,
      plan: 'core',
      rating: 4.6,
      imageUrl: '',
      category: 'family-carer',
    ),
    Course(
      id: 'fam2',
      title: 'Carer Wellbeing and Self-Care',
      description: 'Help carers maintain their wellbeing while providing quality support.',
      durationHours: '6 hrs',
      totalLessons: 24,
      completedLessons: 0,
      progress: 0.0,
      price: 0,
      plan: 'free',
      rating: 4.8,
      imageUrl: '',
      category: 'family-carer',
    ),
    
    // Inclusive Practices
    Course(
      id: 'inc1',
      title: 'Inclusive Practices and Community Participation',
      description: 'Foster inclusion and support meaningful community engagement for participants.',
      durationHours: '10 hrs',
      totalLessons: 40,
      completedLessons: 0,
      progress: 0.0,
      price: 2600,
      plan: 'core',
      rating: 4.7,
      imageUrl: '',
      category: 'inclusive-practices',
    ),
    Course(
      id: 'inc2',
      title: 'Cultural Competency in Disability Support',
      description: 'Develop culturally responsive practices for diverse participant backgrounds.',
      durationHours: '8 hrs',
      totalLessons: 32,
      completedLessons: 0,
      progress: 0.0,
      price: 2400,
      plan: 'core',
      rating: 4.8,
      imageUrl: '',
      category: 'inclusive-practices',
    ),
    
    // Professional Development
    Course(
      id: 'prof1',
      title: 'Professional Ethics and Boundaries',
      description: 'Navigate ethical dilemmas and maintain appropriate professional relationships.',
      durationHours: '7 hrs',
      totalLessons: 28,
      completedLessons: 0,
      progress: 0.0,
      price: 2200,
      plan: 'core',
      rating: 4.6,
      imageUrl: '',
      category: 'professional-development',
    ),
    Course(
      id: 'prof2',
      title: 'Leadership in Disability Services',
      description: 'Develop leadership skills for managing teams and improving service quality.',
      durationHours: '16 hrs',
      totalLessons: 64,
      completedLessons: 0,
      progress: 0.0,
      price: 5200,
      plan: 'elite',
      rating: 4.9,
      imageUrl: '',
      category: 'professional-development',
    ),
    
    // Latest Courses
    Course(
      id: 'latest1',
      title: 'NDIS Practice Standards 2024 Update',
      description: 'Stay compliant with the latest NDIS Practice Standards and regulatory requirements.',
      durationHours: '6 hrs',
      totalLessons: 24,
      completedLessons: 0,
      progress: 0.0,
      price: 0,
      plan: 'free',
      rating: 4.9,
      imageUrl: '',
      category: 'ndis-processes',
    ),
    Course(
      id: 'latest2',
      title: 'Telehealth and Remote Support Delivery',
      description: 'Adapt your support practices for effective remote and telehealth service delivery.',
      durationHours: '9 hrs',
      totalLessons: 36,
      completedLessons: 0,
      progress: 0.0,
      price: 2800,
      plan: 'core',
      rating: 4.8,
      imageUrl: '',
      category: 'support-strategies',
    ),
  ];

  // Generate lessons for a course
  static List<Lesson> getLessonsForCourse(String courseId) {
    final course = allCourses.firstWhere((c) => c.id == courseId);
    
    return List.generate(course.totalLessons, (index) {
      final lessonNumber = index + 1;
      final isCompleted = lessonNumber <= course.completedLessons;
      
      String lessonPlan;
      bool isFree;
      
      if (lessonNumber <= 5) {
        lessonPlan = 'free';
        isFree = true;
      } else {
        lessonPlan = course.plan;
        isFree = false;
      }
      
      return Lesson(
        id: '${courseId}_lesson_$lessonNumber',
        lessonNumber: lessonNumber,
        title: _getLessonTitle(course.title, lessonNumber),
        description: _getLessonDescription(lessonNumber),
        content: _getLessonContent(course.title, lessonNumber),
        durationMinutes: 15 + (lessonNumber % 30),
        isCompleted: isCompleted,
        isFree: isFree,
        plan: lessonPlan,
        videoUrl: '',
      );
    });
  }

  static String _getLessonTitle(String courseTitle, int lessonNumber) {
    final topics = [
      'Introduction and Overview',
      'Core Principles',
      'Practical Applications',
      'Advanced Techniques',
      'Best Practices',
      'Real-world Scenarios',
      'Case Studies',
      'Implementation Strategies',
      'Assessment and Planning',
      'Documentation Requirements',
      'Common Challenges',
      'Quality Improvement',
    ];
    
    return topics[lessonNumber % topics.length];
  }

  static String _getLessonDescription(int lessonNumber) {
    final descriptions = [
      'Build foundational understanding',
      'Learn essential concepts and skills',
      'Hands-on practice with real scenarios',
      'Deep dive into advanced topics',
      'Apply learning to practical situations',
      'Master key techniques and strategies',
    ];
    
    return descriptions[lessonNumber % descriptions.length];
  }

  static String _getLessonContent(String courseTitle, int lessonNumber) {
    return '''
Welcome to Lesson $lessonNumber of $courseTitle!

In this lesson, you'll learn:
• Key concepts and terminology
• Practical implementation techniques
• Real-world applications
• Best practices and common patterns

This lesson builds upon previous concepts and prepares you for more advanced topics ahead.

By the end of this lesson, you'll be able to:
1. Understand the core principles
2. Apply what you've learned to real support situations
3. Solve common challenges
4. Prepare for the next lesson

Let's get started!
    ''';
  }

  // Filter methods
  static List<Course> getFeaturedCourses() {
    return allCourses.where((c) => 
      ['course1', 'course2', 'course3'].contains(c.id)
    ).toList();
  }

  static List<Course> getEnrolledCourses() {
    return allCourses.where((c) => c.completedLessons > 0).toList();
  }

  static List<Course> getRecommendedCourses() {
    return allCourses.where((c) => 
      ['comm1', 'pcc1', 'dls1', 'prof1'].contains(c.id)
    ).toList();
  }

  static List<Course> getLatestCourses() {
    return allCourses.where((c) => c.id.startsWith('latest')).toList();
  }

  static List<Course> getFreeCourses() {
    return allCourses.where((c) => c.plan == 'free').toList();
  }

  static List<Course> getCoursesByPlan(String plan) {
    return allCourses.where((c) => c.plan.toLowerCase() == plan.toLowerCase()).toList();
  }

  static List<Course> getCoursesByCategory(String category) {
    return allCourses.where((c) => c.category == category).toList();
  }

  static Course? getCourseById(String id) {
    try {
      return allCourses.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}