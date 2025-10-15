// lib/app_routes.dart

import 'package:flutter/widgets.dart';
import 'package:kmg/screens/admin/manageusers.dart';

// Importing all screens that are routes
import 'package:kmg/screens/landing/landing_screen.dart';
import 'package:kmg/screens/dashboard/dashboard_screen.dart';
import 'package:kmg/screens/know_more/know_more_screen.dart';
import 'package:kmg/screens/ads/Pre_add_submit_screen.dart';
import 'package:kmg/screens/legal/faq_screen.dart';
import 'package:kmg/screens/matrimony/matri_submit_screen.dart';
import 'package:kmg/screens/settings/profile_screen.dart';
import 'package:kmg/screens/admin/manage_Classifieds_screen.dart';
import 'package:kmg/screens/admin/manageMatrimony.dart';
import 'package:kmg/screens/admin/admin_dashboard_screen.dart';
import 'package:kmg/screens/admin/notifications_screen.dart';
import 'package:kmg/screens/admin/delete_requests_admin_page.dart';
import 'package:kmg/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String dashboard = '/dashboard';
  static const String knowMore = '/knowmore';
  static const String preAdSubmit = '/preadsubmit';
  static const String matrimony = '/matrimony';
  static const String profile = '/profile';
  static const String manageClassifieds = '/manageClassifieds';
  static const String manageMatrimony = '/manageMatrimony';
  static const String adminDashboard = '/adminDashboard';
  static const String notifications = '/notifications';
  static const String deleteRequests = '/delete_request';
  static const String legalpage = '/faqscreen';
  static const String settiingsscreen = '/settingsscreen';
  static const String manageUsersScreen = '/ManageUsersScreen';

  static Map<String, WidgetBuilder> get routes {
    return {
      landing: (context) => const LandingPage(),
      dashboard: (context) => const DashboardScreen(),
      knowMore: (context) => const KnowMoreScreen(),
      preAdSubmit: (context) => const PreAddSubmitScreen(),
      matrimony: (context) => const MatriSubmitScreen(),
      profile: (context) => const ProfileScreen(),
      manageClassifieds: (context) => const ManageClassifiedsScreen(),
      manageMatrimony: (context) => const ManageMatrimonyScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      notifications: (context) => const AddNotificationScreen(),
      deleteRequests: (context) => const DeleteRequestsAdminPage(),
      legalpage: (contxt) => const FAQScreen(),
      settiingsscreen: (context) => const SettingsScreen(),
      manageUsersScreen: (context) => const ManageUsersScreen(),
      // Add alias for /home that routes to /dashboard
      '/home': (context) => const DashboardScreen(),
    };
  }
}
