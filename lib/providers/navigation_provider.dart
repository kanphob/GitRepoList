import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected bottom navigation index.
/// 0 = Home, 1 = Second
final navigationProvider = StateProvider<int>((ref) => 0);
