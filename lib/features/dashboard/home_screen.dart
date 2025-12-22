import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/bottom_navbar.dart';
import '../account/accounts_view.dart';
import '../certificates/certificates_view.dart';
import '../courses/courses_view.dart';
import '../reports/reports_view.dart';
import '../subscriptions/subscriptions_view.dart';
import 'home_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeView(),
          CoursesView(),
          SubscriptionView(),
          ReportsView(),
          AccountView(),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}
