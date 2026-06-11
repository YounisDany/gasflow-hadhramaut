import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/complaints_review_screen.dart';
import '../../presentation/screens/admin/manage_agents_screen.dart';
import '../../presentation/screens/admin/users_management_screen.dart';
import '../../presentation/screens/agent/barcode_scanner_screen.dart';
import '../../presentation/screens/agent/citizen_requests_screen.dart';
import '../../presentation/screens/agent/gas_orders_screen.dart';
import '../../presentation/screens/agent/send_notification_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/citizen/complaints_screen.dart';
import '../../presentation/screens/citizen/order_status_screen.dart';
import '../../presentation/screens/citizen/request_gas_screen.dart';
import '../../presentation/screens/citizen/settings_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/shell/agent_shell.dart';
import '../../presentation/screens/shell/citizen_shell.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/data_registration_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dataRegistration = '/data-registration';
  static const String forgotPassword = '/forgot-password';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String manageAgents = '/admin/manage-agents';
  static const String usersManagement = '/admin/users';
  static const String complaintsReview = '/admin/complaints';

  // Agent
  static const String agentHome = '/agent/home';
  static const String citizenRequests = '/agent/citizen-requests';
  static const String gasOrders = '/agent/gas-orders';
  static const String barcodeScanner = '/agent/barcode';
  static const String sendNotification = '/agent/send-notification';

  // Citizen
  static const String citizenHome = '/citizen/home';
  static const String requestGas = '/citizen/request-gas';
  static const String orderStatus = '/citizen/order-status';
  static const String complaints = '/citizen/complaints';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  /// Builds a fresh screen instance for the route name. Called inside a
  /// [ListenableBuilder] that listens to [L10n.notifier], so each language
  /// toggle hands the framework a NEW widget instance and the page rebuilds.
  static Widget _build(String? name) {
    switch (name) {
      case splash:
        return SplashScreen();
      case onboarding:
        return OnboardingScreen();
      case login:
        return LoginScreen();
      case signup:
        return SignupScreen();
      case dataRegistration:
        return DataRegistrationScreen();
      case forgotPassword:
        return ForgotPasswordScreen();
      case adminDashboard:
        return AdminDashboardScreen();
      case manageAgents:
        return ManageAgentsScreen();
      case usersManagement:
        return UsersManagementScreen();
      case complaintsReview:
        return ComplaintsReviewScreen();
      case agentHome:
        return const AgentShell();
      case citizenRequests:
        return CitizenRequestsScreen();
      case gasOrders:
        return GasOrdersScreen();
      case barcodeScanner:
        return BarcodeScannerScreen();
      case sendNotification:
        return SendNotificationScreen();
      case citizenHome:
        return const CitizenShell();
      case requestGas:
        return RequestGasScreen();
      case orderStatus:
        return OrderStatusScreen();
      case complaints:
        return ComplaintsScreen();
      case settings:
        return SettingsScreen();
      case notifications:
        return NotificationsScreen();
      default:
        return SplashScreen();
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => ListenableBuilder(
        listenable: L10n.notifier,
        builder: (_, __) => _build(settings.name),
      ),
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
