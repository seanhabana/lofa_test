// lib/shared/navigation_utils.dart
import 'package:flutter/material.dart';
import '../features/courses/course_detail_view.dart';
import '../features/courses/lesson_detail_view.dart';
// import '../features/courses/lesson_detail_view.dart'; // Uncomment when ready

class NavigationUtils {
  // Navigate to Course Detail
  static void navigateToCourseDetail(BuildContext context, int courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailView(courseId: courseId),
      ),
    );
  }

  static void navigateToLessonDetail(
    BuildContext context,
    int lessonId,
    int courseId,
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
  final dynamic courseId; // Accept both String and int
  final Widget child;

  const CourseCardWrapper({
    super.key,
    required this.courseId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Convert to int if it's a String
    final int id = courseId is String ? int.parse(courseId) : courseId as int;
    
    return GestureDetector(
      onTap: () => NavigationUtils.navigateToCourseDetail(context, id),
      child: child,
    );
  }
}

// Slide up route animation
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