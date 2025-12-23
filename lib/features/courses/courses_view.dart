import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';

class CoursesView extends ConsumerStatefulWidget {
  const CoursesView({super.key});

  @override
  ConsumerState<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends ConsumerState<CoursesView> {
  String selectedCategory = 'All';
  final categories = ['All', 'Latest', 'Free', 'Core', 'Pro', 'Elite'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> _filterCourses(List<Course> courses) {
    if (_searchQuery.isEmpty) return courses;
    
    return courses.where((course) {
      final titleMatch = course.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final descMatch = course.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || descMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(coursesViewModelProvider);

    return coursesState.when(
      data: (data) => _buildCoursesContent(context, data),
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
    );
  }

  Widget _buildCoursesContent(BuildContext context, CoursesState state) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedCategory == 'All' || selectedCategory == 'Latest')
                    _buildSection(
                      title: 'Latest Courses',
                      courses: _filterCourses(state.latestCourses),
                      showBadge: true,
                      badgeText: 'NEW',
                      badgeColor: const Color(0xFF581C87),
                    ),
                  if (selectedCategory == 'All' || selectedCategory == 'Free')
                    _buildSection(
                      title: 'Free Courses',
                      courses: _filterCourses(state.freeCourses),
                      showBadge: true,
                      badgeText: 'FREE',
                      badgeColor: Colors.green,
                    ),
                  if (selectedCategory == 'All' || selectedCategory == 'Core')
                    _buildSection(
                      title: 'Core Plan Courses',
                      courses: _filterCourses(state.corePlanCourses),
                      showBadge: true,
                      badgeText: 'CORE',
                      badgeColor: const Color(0xFF9D65AA),
                    ),
                  if (selectedCategory == 'All' || selectedCategory == 'Pro')
                    _buildSection(
                      title: 'Pro Plan Courses',
                      courses: _filterCourses(state.proPlanCourses),
                      showBadge: true,
                      badgeText: 'PRO',
                      badgeColor: const Color(0xFF581C87),
                    ),
                  if (selectedCategory == 'All' || selectedCategory == 'Elite')
                    _buildSection(
                      title: 'Elite Plan Courses',
                      courses: _filterCourses(state.elitePlanCourses),
                      showBadge: true,
                      badgeText: 'ELITE',
                      badgeColor: Colors.amber.shade700,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Courses',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF581C87),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore our comprehensive course catalog',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search courses...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF581C87) : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Course> courses,
    bool showBadge = false,
    String? badgeText,
    Color? badgeColor,
  }) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return _buildCourseCard(
              courses[index],
              showBadge: showBadge,
              badgeText: badgeText,
              badgeColor: badgeColor,
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCourseCard(
    Course course, {
    bool showBadge = false,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (showBadge && badgeText != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor ?? const Color(0xFF581C87),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.durationHours,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.totalLessons} lessons',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
    );
  }
}

// Add this to your course_provider.dart file
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
        description:
            'Build full-stack applications with the latest Next.js features including server components and app router.',
        durationHours: '18 hrs',
        totalLessons: 65,
        completedLessons: 0,
        progress: 0.0,
        price: 3500,
        plan: 'free',

        rating: 4.9,
        imageUrl: '',
      ),
      Course(
        id: 'latest2',
        title: 'AI and Machine Learning Fundamentals',
        description:
            'Introduction to artificial intelligence, neural networks, and practical ML applications.',
        durationHours: '20 hrs',
        totalLessons: 72,
        completedLessons: 0,
        progress: 0.0,
        price: 4200,
        plan: 'core',

        rating: 4.8,
        imageUrl: '',
      ),
      Course(
        id: 'latest3',
        title: 'Cybersecurity Essentials for Developers',
        description:
            'Learn security best practices, encryption, authentication, and how to protect applications.',
        durationHours: '12 hrs',
        totalLessons: 45,
        completedLessons: 0,
        progress: 0.0,
        price: 3000,
        plan: 'pro',

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
        description:
            'Start your coding journey with basic programming concepts and problem-solving.',
        durationHours: '8 hrs',
        totalLessons: 30,
        completedLessons: 0,
        plan: 'free',

        progress: 0.0,
        price: 0,
        rating: 4.5,
        imageUrl: '',
      ),
      Course(
        id: 'free2',
        title: 'Git Version Control Basics',
        description:
            'Master the fundamentals of Git for tracking code changes and collaborating.',
        durationHours: '4 hrs',
        totalLessons: 15,
        completedLessons: 0,
        plan: 'free',

        progress: 0.0,
        price: 0,
        rating: 4.6,
        imageUrl: '',
      ),
      Course(
        id: 'free3',
        title: 'HTML & CSS Crash Course',
        description:
            'Build beautiful websites from scratch using HTML5 and CSS3.',
        durationHours: '6 hrs',
        totalLessons: 25,
        completedLessons: 0,
        plan: 'free',

        progress: 0.0,
        price: 0,
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
        description:
            'Master JavaScript from basics to advanced concepts including ES6+ features.',
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
        description:
            'Build modern web applications with React, hooks, context, and state management.',
        durationHours: '16 hrs',
        totalLessons: 60,
        completedLessons: 0,
        plan: 'core',

        progress: 0.0,
        price: 2500,
        rating: 4.8,
        imageUrl: '',
      ),
      Course(
        id: 'core3',
        title: 'Node.js Backend Development',
        description:
            'Create scalable backend APIs with Node.js, Express, and MongoDB.',
        durationHours: '14 hrs',
        totalLessons: 50,
        completedLessons: 0,
        progress: 0.0,
        plan: 'core',

        price: 2400,
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
        description:
            'Deep dive into Flutter animations, custom widgets, and performance optimization.',
        durationHours: '22 hrs',
        totalLessons: 85,
        completedLessons: 0,
        progress: 0.0,
        plan: 'pro',

        price: 3800,
        rating: 4.9,
        imageUrl: '',
      ),
      Course(
        id: 'pro2',
        title: 'AWS Cloud Architecture',
        description:
            'Design and deploy scalable cloud solutions using AWS services and best practices.',
        durationHours: '20 hrs',
        totalLessons: 75,
        completedLessons: 0,
        plan: 'pro',

        progress: 0.0,
        price: 4000,
        rating: 4.8,
        imageUrl: '',
      ),
      Course(
        id: 'pro3',
        title: 'Microservices with Docker & Kubernetes',
        description:
            'Build, containerize, and orchestrate microservices architecture.',
        durationHours: '18 hrs',
        totalLessons: 68,
        completedLessons: 0,
        plan: 'pro',

        progress: 0.0,
        price: 3600,
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
        description:
            'Design large-scale distributed systems with real-world case studies and patterns.',
        durationHours: '25 hrs',
        totalLessons: 95,
        completedLessons: 0,
        progress: 0.0,
        plan: 'elite',

        price: 5500,
        rating: 5.0,
        imageUrl: '',
      ),
      Course(
        id: 'elite2',
        title: 'Advanced Data Structures & Algorithms',
        description:
            'Master complex algorithms and data structures for technical interviews and optimization.',
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
        description:
            'Build decentralized applications with Solidity, Web3.js, and smart contracts.',
        durationHours: '28 hrs',
        totalLessons: 100,
        completedLessons: 0,
        plan: 'elite',

        progress: 0.0,
        price: 5800,
        rating: 4.8,
        imageUrl: '',
      ),
    ];
  }
}

final coursesViewModelProvider =
    StateNotifierProvider<CoursesViewModel, AsyncValue<CoursesState>>((ref) {
      return CoursesViewModel();
    });
