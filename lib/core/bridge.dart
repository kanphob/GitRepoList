import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridge to access shell-level features without a direct dependency.
/// Overridden by app_core at the root.

/// Defaults to true. Core shells should override this to false.
final isStandaloneProvider = Provider<bool>((ref) => true);

final shellTokenProvider = Provider<String>((ref) => 'N/A');

/// Default user data for standalone mode.
final shellUserProvider = Provider<Map<String, dynamic>>((ref) => {
  'username': 'kanphob',
  'email': 'standalone@example.com',
  'displayName': 'Standalone User',
});

final shellRouteProvider = Provider<void Function(String)>((ref) => (p) {
  debugPrint('Shell Route: $p');
});

final shellLogoutProvider = Provider<void Function()>((ref) => () {
  debugPrint('Shell Logout triggered');
});

final shellSessionExpiredProvider = Provider<void Function()>((ref) => () {
  debugPrint('Shell Session Expired triggered');
});

