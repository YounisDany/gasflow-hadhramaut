import 'package:flutter/widgets.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/messaging_service.dart';
import '../routes/app_routes.dart';
import '../session/session.dart';
import 'prefs.dart';

/// Decides the post-splash / post-onboarding destination from the current auth
/// state and navigates there, replacing the current route. Shared by the splash
/// and onboarding screens so routing lives in exactly one place.
Future<void> goToStartDestination(BuildContext context) async {
  // Demo mode (Firebase not configured) or signed-out: browse as a guest.
  // Sign-in is only required for actions (requesting gas, orders, complaints).
  if (!AuthService.ready || AuthService.currentUser == null) {
    // Restore a previously remembered local session so the user stays signed
    // in across launches (demo mode only — real Firebase persists on its own).
    if (!AuthService.ready && Prefs.signedIn) {
      final role = Prefs.sessionRole;
      Session.isGuest = false;
      Session.role = role;
      Session.saveProfile(
        name: Prefs.sessionName,
        email: Prefs.sessionEmail,
        phone: Prefs.sessionPhone,
        region: Prefs.sessionRegion,
        lat: Prefs.sessionLat,
        lng: Prefs.sessionLng,
      );
      Session.profileComplete = Prefs.sessionProfileComplete;
      Session.isJoined = Prefs.sessionIsJoined;
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, _routeForRole(role));
      }
      return;
    }
    Session.isGuest = true;
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.citizenHome);
    }
    return;
  }

  Session.isGuest = false;
  final role = await AuthService.roleForCurrentUser();
  final prof = await AuthService.profileForCurrentUser();
  if (prof != null) {
    Session.saveProfile(
      name: prof['name'] as String?,
      email: prof['email'] as String?,
      phone: prof['phone'] as String?,
      region: prof['region'] as String?,
    );
    Session.profileComplete = prof['profileComplete'] == true;
    Session.isJoined = prof['isJoined'] == true;
  }
  Session.role = role;
  await MessagingService.registerToken();
  if (!context.mounted) return;
  Navigator.pushReplacementNamed(context, _routeForRole(role));
}

String _routeForRole(String role) => role == 'admin'
    ? AppRoutes.adminDashboard
    : role == 'agent'
        ? AppRoutes.agentHome
        : AppRoutes.citizenHome;
