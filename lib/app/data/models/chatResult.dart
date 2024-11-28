import 'dart:ui';

class SearchResult {
  final String name;
  final Color color;
  final String? lastMessage;
  final String? time;
  final bool isProfile;

  SearchResult({
    required this.name,
    required this.color,
    this.lastMessage,
    this.time,
    required this.isProfile,
  });
}