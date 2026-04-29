import 'package:flutter/material.dart';
import 'package:git_repo_list/core/bridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart';

/// UserSession passed from the core app into this mini-app.
class UserSession {
  final String userId;
  final String email;
  final String displayName;
  final String accessToken;

  const UserSession({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.accessToken,
  });
}

/// The public entry-point widget that core app uses to launch git_repo_list.
class GitRepoListMiniApp extends StatelessWidget {
  final UserSession? session;

  const GitRepoListMiniApp({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    // We no longer need the local ProviderScope overrides because the core app
    // handles them at the root ProviderScope level. This prevents duplicate key errors.
    return const HomePage();
  }
}
