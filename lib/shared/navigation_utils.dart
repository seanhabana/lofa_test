// lib/shared/navigation_utils.dart
import 'package:flutter/material.dart';
import '../providers/course_provider.dart';
import '../features/courses/course_detail_view.dart';
import '../features/courses/lesson_detail_view.dart';
class NavigationUtils {
  // Navigate to Course Detail
  static void navigateToCourseDetail(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailView(courseId: courseId),
      ),
    );
  }

  // Navigate to Lesson Detail
  static void navigateToLessonDetail(
    BuildContext context,
    String lessonId,
    String courseId,
  ) {
    Navigator.push(
      context,
      slideUpRoute(
        LessonDetailView(
          lessonId: lessonId,
          courseId: courseId,
        ),
      ),
    );
  }
}

// Reusable Course Card Wrapper
class CourseCardWrapper extends StatelessWidget {
  final String courseId;
  final Widget child;

  const CourseCardWrapper({
    super.key,
    required this.courseId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NavigationUtils.navigateToCourseDetail(context, courseId),
      child: child,
    );
  }
}

// Slide up route animation (from utils.dart)
Route slideUpRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

// Slide left route animation
Route slideLeftRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

// Slide right route animation
Route slideRightRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}