import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/transactions/presentation/pages/transactions_list_page.dart';
import '../../features/transactions/presentation/pages/transaction_search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/analytics/presentation/pages/mood_analytics_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/ocr/presentation/pages/scan_receipt_page.dart';
import '../../features/geofencing/presentation/pages/geofence_page.dart';
import '../../features/vault/presentation/pages/vault_page.dart';
import '../../features/sync/presentation/pages/sync_page.dart';
import '../../features/recurring/presentation/pages/recurring_page.dart';
import '../../features/currency/presentation/pages/currency_page.dart';
import '../../features/split/presentation/pages/split_page.dart';
import '../../features/bills/presentation/pages/bills_page.dart';
import '../../shared/widgets/main_scaffold.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      routes: _routes,
    );
  }

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: _routes,
  );

  static final _routes = [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            pageBuilder: (context, state) => const NoTransitionPage(child: AnalyticsPage()),
          ),
          GoRoute(
            path: '/budget',
            name: 'budget',
            pageBuilder: (context, state) => const NoTransitionPage(child: BudgetPage()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
      
      // Full screen routes
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AddTransactionPage(prefilledData: extra);
        },
      ),
      GoRoute(
        path: '/edit-transaction/:id',
        name: 'edit-transaction',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AddTransactionPage(transactionId: id);
        },
      ),
      GoRoute(
        path: '/transaction/:id',
        name: 'transaction-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TransactionDetailPage(transactionId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/mood-analytics',
        builder: (context, state) => const MoodAnalyticsPage(),
      ),
      GoRoute(
        path: '/scan-receipt',
        builder: (context, state) => const ScanReceiptPage(),
      ),
      GoRoute(
        path: '/geofence',
        builder: (context, state) => const GeofencePage(),
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultPage(),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      // v3.2 Routes
      GoRoute(
        path: '/recurring',
        name: 'recurring',
        builder: (context, state) => const RecurringPage(),
      ),
      GoRoute(
        path: '/currency',
        name: 'currency',
        builder: (context, state) => const CurrencyPage(),
      ),
      GoRoute(
        path: '/split',
        name: 'split',
        builder: (context, state) => const SplitPage(),
      ),
      GoRoute(
        path: '/bills',
        name: 'bills',
        builder: (context, state) => const BillsPage(),
      ),
      // Transactions routes
      GoRoute(
        path: '/transactions',
        name: 'transactions-list',
        builder: (context, state) => const TransactionsListPage(),
      ),
      GoRoute(
        path: '/transactions/search',
        name: 'transactions-search',
        builder: (context, state) => const TransactionSearchPage(),
      ),
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ];
}
