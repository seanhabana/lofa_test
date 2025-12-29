import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/course_models.dart';
import '../../providers/course_provider.dart';
import '../../shared/navigation_utils.dart';
import '../../shared/plan_badge.dart';

class CoursesView extends ConsumerStatefulWidget {
  const CoursesView({super.key});

  @override
  ConsumerState<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends ConsumerState<CoursesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFilters = false;
  String _selectedPlanFilter = 'All';
  String _sortBy = 'default';

  final planFilters = ['All', 'Free', 'Core', 'Pro', 'Elite'];
  final sortOptions = [
    {'value': 'default', 'label': 'Default'},
    {'value': 'rating', 'label': 'Highest Rated'},
    {'value': 'duration', 'label': 'Duration'},
    {'value': 'newest', 'label': 'Newest First'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> _filterAndSortCourses(List<Course> courses) {
    var filtered = courses;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((course) {
        final titleMatch = course.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final descMatch = course.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return titleMatch || descMatch;
      }).toList();
    }
    
    // Apply plan filter
    if (_selectedPlanFilter != 'All') {
      filtered = filtered.where((course) => 
        course.plan.toLowerCase() == _selectedPlanFilter.toLowerCase()
      ).toList();
    }
    
    // Apply sorting
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'duration':
        filtered.sort((a, b) => a.estimatedDurationMinutes.compareTo(b.estimatedDurationMinutes));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        // Keep default order
        break;
    }
    
    return filtered;
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(coursesViewModelProvider),
              child: const Text('Retry'),
            ),
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
          if (_showFilters) _buildFilterSection(),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF581C87),
              onRefresh: () async {
                ref.invalidate(coursesViewModelProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Latest Courses
                    if (_selectedPlanFilter == 'All')
                      _buildSection(
                        title: 'Latest Courses',
                        courses: _filterAndSortCourses(state.latestCourses),
                        showBadge: true,
                        badgeText: 'NEW',
                        badgeColor: const Color(0xFF581C87),
                      ),
                    
                    // Free Courses
                    if (_selectedPlanFilter == 'All' || _selectedPlanFilter == 'Free')
                      _buildSection(
                        title: 'Free Courses',
                        courses: _filterAndSortCourses(state.freeCourses),
                        icon: Icons.public,
                        iconColor: Colors.green,
                      ),
                    
                    // Core Plan Courses
                    if (_selectedPlanFilter == 'All' || _selectedPlanFilter == 'Core')
                      _buildSection(
                        title: 'Core Plan Courses',
                        courses: _filterAndSortCourses(state.corePlanCourses),
                        icon: Icons.workspace_premium,
                        iconColor: const Color(0xFF9D65AA),
                      ),
                    
                    // Pro Plan Courses
                    if (_selectedPlanFilter == 'All' || _selectedPlanFilter == 'Pro')
                      _buildSection(
                        title: 'Pro Plan Courses',
                        courses: _filterAndSortCourses(state.proPlanCourses),
                        icon: Icons.star,
                        iconColor: const Color(0xFF581C87),
                      ),
                    
                    // Elite Plan Courses
                    if (_selectedPlanFilter == 'All' || _selectedPlanFilter == 'Elite')
                      _buildSection(
                        title: 'Elite Plan Courses',
                        courses: _filterAndSortCourses(state.elitePlanCourses),
                        icon: Icons.diamond,
                        iconColor: Colors.amber.shade700,
                      ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _showFilters ? const Color(0xFF581C87) : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: _showFilters ? Colors.white : Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Filter
          Text(
            'Plan Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: planFilters.map((plan) {
              final isSelected = _selectedPlanFilter == plan;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlanFilter = plan;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF581C87) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF581C87) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    plan,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Sort By
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortOptions.map((option) {
              final value = option['value'] as String;
              final label = option['label'] as String;
              final isSelected = _sortBy == value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _sortBy = value;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF581C87) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF581C87) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Course> courses,
    bool showBadge = false,
    String? badgeText,
    Color? badgeColor,
    IconData? icon,
    Color? iconColor,
  }) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${courses.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
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
              context,
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
  BuildContext context,
  Course course, {
  bool showBadge = false,
  String? badgeText,
  Color? badgeColor,
}) {
  final imageUrl = course.imageUrl;

  return CourseCardWrapper(
    courseId: course.id.toString(),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140, // Add fixed height
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 120,
                        height: 140,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 140,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF9D65AA),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 140,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 120,
                        height: 140,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 36,
                            color: Colors.grey,
                          ),
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
          
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          course.title.isNotEmpty ? course.title : 'Untitled Course',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PlanBadgeCompact(plan: course.plan),
                    ],
                  ),
                  
                  // Description
                  Text(
                    course.shortDescription.isNotEmpty
                        ? course.shortDescription
                        : (course.description.isNotEmpty 
                            ? course.description 
                            : 'No description available'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Stats Row
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toStringAsFixed(1),
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
                      Flexible(
                        child: Text(
                          '${course.totalLessons} lessons',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
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