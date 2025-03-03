import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class NameGenerator {
  static final NameGenerator _instance = NameGenerator._internal();
  late Map<String, dynamic> _prefixes;
  late Map<String, dynamic> _conjunctions;
  late Map<String, dynamic> _suffixes;
  final Random _random = Random();

  // 私有构造函数
  NameGenerator._internal();

  // 工厂构造函数
  factory NameGenerator() {
    return _instance;
  }

  static Future<void> initialize() async {
    await _instance._loadResources();
  }

  Future<void> _loadResources() async {
    _prefixes = await _loadJson('assets/prefixes.json');
    _conjunctions = await _loadJson('assets/conjunction.json');
    _suffixes = await _loadJson('assets/suffixes.json');
  }

  static Future<Map<String, dynamic>> _loadJson(String path) async {
    final data = await rootBundle.loadString(path);
    return json.decode(data);
  }

  String generate() {
    final parts = [
      _getRandomElement(_prefixes),
      _random.nextDouble() < 0.3 ? _getRandomElement(_conjunctions) : null,
      _getRandomElement(_suffixes),
    ];

    return parts.where((p) => p != null).join();
  }

  String _getRandomElement(Map<String, dynamic> data) {
    final categoryKey = data.keys.elementAt(_random.nextInt(data.keys.length));
    final category = data[categoryKey];

    if (category is Map<String, dynamic>) {
      return _getRandomElement(category);
    }

    if (category is List) {
      return (category[_random.nextInt(category.length)] as String).replaceAll(
        RegExp(r'[··]'),
        '',
      );
    }

    return '';
  }
}
