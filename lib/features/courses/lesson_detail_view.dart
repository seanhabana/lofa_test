import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart';
import '../../models/lesson_models.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_session_provider.dart';
import '../../services/course_service.dart';
import '../../shared/widgets/congratulations_modal.dart';
import 'write_review_view.dart';

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
  VideoPlayerController? _videoController;
  bool _isVideoLoading = true;
  bool _isMarkingComplete = false;
  bool _hasMarkedComplete = false;
  int _totalWatchTimeSeconds = 0;
  DateTime? _lastUpdateTime;
  int? _videoDurationSeconds;
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _startProgressTracking();
  }

  void _startProgressTracking() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _updateProgress();
        _startProgressTracking();
      }
    });
  }

  String _convertToHLS(String embedUrl) {
    final pullZoneHost = dotenv.env['BUNNY_PULL_ZONE_HOST'];
    
    try {
      final uri = Uri.parse(embedUrl);
      final segments = uri.pathSegments;
      
      if (segments.length >= 3 && segments[0] == 'embed') {
        final videoId = segments[2];
        return '$pullZoneHost/$videoId/playlist.m3u8';
      }
      
      return embedUrl;
    } catch (e) {
      print('⚠️ Failed to convert URL: $e');
      return embedUrl;
    }
  }

  Future<void> _initializeVideo(String embedUrl) async {
    try {
      final hlsUrl = _convertToHLS(embedUrl);
      print('🎥 Loading HLS: $hlsUrl');

      _videoController = VideoPlayerController.networkUrl(Uri.parse(hlsUrl));
      
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _videoDurationSeconds = _videoController!.value.duration.inSeconds;
          _lastUpdateTime = DateTime.now();
        });

        print('✅ Video initialized: ${_videoDurationSeconds}s');
        _videoController!.addListener(_videoListener);
      }
    } catch (e) {
      print('❌ Video initialization failed: $e');
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    // Update UI if not seeking
    if (!_isSeeking && mounted) {
      setState(() {});
    }

    final position = _videoController!.value.position.inSeconds;
    final duration = _videoController!.value.duration.inSeconds;

    if (!_hasMarkedComplete && duration > 0 && position >= duration - 2) {
      print('🎬 Video ended at ${position}s / ${duration}s');
      _hasMarkedComplete = true;
      _markLessonComplete();
    }
  }

  Future<void> _updateProgress() async {
    final authState = ref.read(authSessionProvider);
    final token = authState.token;
    
    if (token == null || _videoController == null) return;

    final now = DateTime.now();
    if (_lastUpdateTime != null && _videoController!.value.isPlaying) {
      final elapsed = now.difference(_lastUpdateTime!).inSeconds;
      _totalWatchTimeSeconds += elapsed;
    }
    _lastUpdateTime = now;

    if (_videoDurationSeconds == null || _videoDurationSeconds! <= 0) return;

    final currentPosition = _videoController!.value.position.inSeconds;
    final progressPercentage = (currentPosition / _videoDurationSeconds!) * 100;
    
    print('📊 Progress: ${progressPercentage.toStringAsFixed(1)}% (${currentPosition}s / ${_videoDurationSeconds}s)');

    await CourseService.updateLessonProgress(
      lessonId: widget.lessonId,
      token: token,
      watchTimeSeconds: _totalWatchTimeSeconds,
      lastPositionSeconds: currentPosition,
      progressPercentage: progressPercentage.clamp(0.0, 100.0),
      completed: false,
    );
  }

  Future<void> _markLessonComplete() async {
    if (_isMarkingComplete) return;
    
    setState(() {
      _isMarkingComplete = true;
    });

    final authState = ref.read(authSessionProvider);
    final token = authState.token;
    
    if (token == null) {
      setState(() {
        _isMarkingComplete = false;
      });
      return;
    }

    try {
      // Get current state before marking complete
      final currentCourseDetail = await ref.read(courseDetailProvider(widget.courseId).future);
      final wasLessonCompleted = currentCourseDetail.userProgress.isLessonCompleted(widget.lessonId);
      final previousProgress = currentCourseDetail.userProgress.progressPercentage;
      
      final success = await CourseService.markLessonCompleted(
        lessonId: widget.lessonId,
        token: token,
      );

      if (success && mounted) {
        ref.invalidate(courseDetailProvider(widget.courseId));
        
        // Only show toast if lesson was not previously completed
        if (!wasLessonCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Lesson completed! 🎉'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Check if course just became 100% complete
        await Future.delayed(const Duration(milliseconds: 500));
        final updatedCourseDetail = await ref.refresh(courseDetailProvider(widget.courseId).future);
        
        // Only show modal if course JUST reached 100% (wasn't 100% before)
        if (updatedCourseDetail.userProgress.progressPercentage >= 100 && previousProgress < 100) {
          _showCongratulationsModal(updatedCourseDetail);
        }
      }
    } catch (e) {
      print('❌ Error marking lesson complete: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingComplete = false;
        });
      }
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _skipSeconds(int seconds) {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    
    final currentPosition = _videoController!.value.position;
    final duration = _videoController!.value.duration;
    final newPosition = currentPosition + Duration(seconds: seconds);
    
    if (newPosition < Duration.zero) {
      _videoController!.seekTo(Duration.zero);
    } else if (newPosition > duration) {
      _videoController!.seekTo(duration);
    } else {
      _videoController!.seekTo(newPosition);
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _videoController != null && _videoController!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showCongratulationsModal(CourseDetail courseDetail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CongratulationsModal(
        courseTitle: courseDetail.course.title,
        onWriteReview: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WriteReviewView(
                courseId: widget.courseId,
                courseTitle: courseDetail.course.title,
              ),
            ),
          );
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _updateProgress();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseDetailState = ref.watch(courseDetailProvider(widget.courseId));

    if (_isFullScreen) {
      return _buildFullScreenPlayer();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: courseDetailState.when(
        data: (courseDetail) {
          final lesson = _findLesson(courseDetail);
          if (lesson == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Lesson not found'),
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

  Widget _buildFullScreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (!_showControls) {
              // If controls are hidden, just show them
              setState(() {
                _showControls = true;
              });
              _hideControlsAfterDelay();
            }
            // If controls are already shown, do nothing (let buttons handle their own taps)
          },
          child: Stack(
            children: [
              Center(
                child: _videoController != null && _videoController!.value.isInitialized
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height,
                        ),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),
              if (_videoController != null && _videoController!.value.isInitialized)
                _buildEnhancedVideoControls(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate video height based on aspect ratio
    final videoAspectRatio = _videoController?.value.isInitialized == true
        ? _videoController!.value.aspectRatio
        : 16 / 9; // Default 16:9 aspect ratio
    
    final videoHeight = screenWidth / videoAspectRatio;
    final expandedHeight = videoHeight.clamp(200.0, 500.0) + topPadding;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: expandedHeight,
          pinned: true,
          backgroundColor: const Color(0xFF0A1929),
          leading: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
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

    if (_videoController == null) {
      _initializeVideo(lesson.videoUrl);
    }

    return GestureDetector(
      onTap: () {
        if (!_showControls) {
          setState(() {
            _showControls = true;
          });
          _hideControlsAfterDelay();
        }
      },
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: _videoController != null && _videoController!.value.isInitialized
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 500, // Max height for larger screens
                      ),
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (_videoController != null && _videoController!.value.isInitialized)
            _buildEnhancedVideoControls(),
          if (_isVideoLoading)
            Container(
              color: const Color(0xFF0A1929),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedVideoControls() {
  final duration = _videoController!.value.duration;
  final position = _videoController!.value.position;

  return AnimatedOpacity(
    opacity: _showControls ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 300),
    child: IgnorePointer(
      ignoring: !_showControls, 
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.replay_5,
                    onPressed: () => _skipSeconds(-5),
                    size: 40,
                  ),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    onPressed: () {
                      setState(() {
                        _showControls = true; 
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                          _hideControlsAfterDelay();
                        }
                      });
                    },
                    size: 56,
                  ),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: Icons.forward_5,
                    onPressed: () => _skipSeconds(5),
                    size: 40,
                  ),
                ],
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    if (_isFullScreen)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _toggleFullScreen,
                      ),
                  ],
                ),
              ),
            ),

            // Bottom controls bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape:
                                  const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape:
                                  const RoundSliderOverlayShape(overlayRadius: 14),
                              activeTrackColor: const Color(0xFF581C87),
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: const Color(0xFF581C87),
                              overlayColor: const Color(0xFF581C87).withOpacity(0.3),
                            ),
                            child: Slider(
                              value: position.inSeconds
                                  .toDouble()
                                  .clamp(0.0, duration.inSeconds.toDouble()),
                              min: 0.0,
                              max: duration.inSeconds.toDouble(),
                              onChangeStart: (value) {
                                setState(() {
                                  _isSeeking = true;
                                });
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                              onChangeEnd: (value) {
                                _videoController!
                                    .seekTo(Duration(seconds: value.toInt()));
                                setState(() {
                                  _isSeeking = false;
                                });
                                _hideControlsAfterDelay();
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Bottom row with play button and fullscreen
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _videoController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _showControls = true;
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                                _hideControlsAfterDelay();
                              }
                            });
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        onPressed: onPressed,
        padding: EdgeInsets.all(size * 0.3),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
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
            lesson.content.isNotEmpty ? lesson.content : 'No description available',
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