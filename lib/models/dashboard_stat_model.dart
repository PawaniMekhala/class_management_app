import 'package:flutter/material.dart';

class DashboardStatModel {
  final String title;
  final String value;
  final String? subtitle;
  final Color valueColor;

  const DashboardStatModel({
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor = const Color(0xFF293B78),
  });
}
