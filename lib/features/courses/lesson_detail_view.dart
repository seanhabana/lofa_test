import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/lesson_models.dart';
import '../../models/course_models.dart';
import '../../providers/course_provider.dart';
import '../../shared/navigation_utils.dart';

class LessonDetailView extends ConsumerStatefulWidget {
  final int lessonId;
  final int courseId;

  const LessonDetailView({
    super.key,
    required this.lessonId,
    required this.courseId,
  });

  @override
  ConsumerState<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends ConsumerState<LessonDetailView> {
  WebViewController? _webViewController;
  bool _isVideoLoading = true;
  double _videoAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    // Enable auto-rotation for fullscreen video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset to portrait only when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseDetailState = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: courseDetailState.when(
        data: (courseDetail) {
          final lesson = _findLesson(courseDetail);
          if (lesson == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Lesson not found'),
                ],
              ),
            );
          }
          return _buildContent(context, lesson, courseDetail);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF581C87)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Lesson? _findLesson(CourseDetail courseDetail) {
    for (final module in courseDetail.modules) {
      for (final lesson in module.lessons) {
        if (lesson.id == widget.lessonId) {
          return lesson;
        }
      }
    }
    return null;
  }

  bool _isLessonCompleted(CourseDetail courseDetail) {
    return courseDetail.userProgress.isLessonCompleted(widget.lessonId);
  }

  Widget _buildContent(BuildContext context, Lesson lesson, CourseDetail courseDetail) {
    final isCompleted = _isLessonCompleted(courseDetail);
    final topPadding = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 190 + topPadding,
          pinned: true,
          backgroundColor: const Color(0xFF0A1929),
          leading: Padding(
            padding: EdgeInsets.only(top: 0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                SizedBox(height: topPadding),
                Expanded(
                  child: _buildVideoPlayer(lesson),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLessonInfo(lesson, isCompleted),
              const SizedBox(height: 24),
              _buildLessonContent(lesson),
              const SizedBox(height: 24),
              _buildNavigationButtons(context, lesson, courseDetail),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(Lesson lesson) {
    if (!lesson.userHasAccess) {
      return Container(
        color: const Color(0xFF0A1929),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Upgrade to ${lesson.plan.toUpperCase()} plan',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (lesson.videoUrl.isEmpty) {
      return Container(
        color: const Color(0xFF0A1929),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined, size: 80, color: Colors.white54),
              SizedBox(height: 16),
              Text(
                'No video available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: _buildVideoWebView(lesson),
        ),
        if (_isVideoLoading)
          Container(
            color: const Color(0xFF0A1929),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoWebView(Lesson lesson) {
    // Initialize WebView controller if needed
    if (_webViewController == null && lesson.videoUrl.isNotEmpty) {
      _initializeWebView(lesson.videoUrl);
    }

    return AspectRatio(
      aspectRatio: _videoAspectRatio,
      child: _webViewController != null
          ? WebViewWidget(controller: _webViewController!)
          : const SizedBox.shrink(),
    );
  }

  void _initializeWebView(String embedUrl) {
    print('🎥 Initializing WebView for: $embedUrl');

    // Create HTML wrapper for the iframe with native fullscreen support
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: #000;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
  </style>
</head>
<body>
  <iframe 
    src="$embedUrl" 
    loading="eager" 
    allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture; fullscreen;" 
    allowfullscreen="true"
    webkitallowfullscreen="true"
    mozallowfullscreen="true">
  </iframe>
</body>
</html>
''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📺 Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('✅ Page finished loading: $url');
            if (mounted) {
              setState(() {
                _isVideoLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                _isVideoLoading = false;
              });
            }
          },
        ),
      )
      ..loadHtmlString(html);

    setState(() {});
  }

  Widget _buildLessonInfo(Lesson lesson, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF581C87).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Color(0xFF581C87)),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.durationMinutes}m',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF581C87),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(lesson.difficulty),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lesson.difficulty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lesson.isFree ? Colors.green : _getPlanColor(lesson.plan),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lesson.isFree ? 'FREE' : lesson.plan.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Lesson ${lesson.sortOrder}: ${lesson.title}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.content.isNotEmpty
                ? lesson.content
                : 'No description available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Lesson',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.video_library, 'Type', lesson.type.toUpperCase()),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.schedule, 'Duration', '${lesson.durationMinutes} minutes'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.signal_cellular_alt, 'Difficulty', lesson.difficulty),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lesson.content.isNotEmpty
                ? lesson.content
                : 'Watch the video above to learn more about ${lesson.title.toLowerCase()}.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF581C87)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, Lesson lesson, CourseDetail courseDetail) {
    final allLessons = <Lesson>[];
    for (final module in courseDetail.modules) {
      allLessons.addAll(module.lessons);
    }

    final currentIndex = allLessons.indexWhere((l) => l.id == lesson.id);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < allLessons.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: hasPrevious
                  ? () {
                      final previousLesson = allLessons[currentIndex - 1];
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LessonDetailView(
                            lessonId: previousLesson.id,
                            courseId: widget.courseId,
                          ),
                        ),
                      );
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: hasPrevious ? const Color(0xFF581C87) : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: hasPrevious ? const Color(0xFF581C87) : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasPrevious ? const Color(0xFF581C87) : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: hasNext
                  ? () {
                      final nextLesson = allLessons[currentIndex + 1];
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LessonDetailView(
                            lessonId: nextLesson.id,
                            courseId: widget.courseId,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: hasNext ? const Color(0xFF581C87) : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next Lesson',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasNext ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: hasNext ? Colors.white : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'core':
        return const Color(0xFF9D65AA);
      case 'pro':
        return const Color(0xFF581C87);
      case 'elite':
        return Colors.amber.shade700;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'basic':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}