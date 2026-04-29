import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_repo_list/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      overrides: [
        // Example: Override for standalone testing
        // isStandaloneProvider.overrideWithValue(true),
        // shellUserProvider.overrideWithValue({'username': 'custom_user'}),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitRepo App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const HomePage(),
    );
  }
}


