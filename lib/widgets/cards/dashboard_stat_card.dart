import 'package:flutter/material.dart';

import '../../models/dashboard_stat_model.dart';

class DashboardStatCard extends StatelessWidget {
  final DashboardStatModel stat;
  final VoidCallback? onTap;

  const DashboardStatCard({super.key, required this.stat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 105),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card title
              Text(
                stat.title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF526184)),
              ),

              const Spacer(),

              // Main statistic
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: stat.valueColor,
                  ),
                ),
              ),

              // Optional subtitle
              if (stat.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  stat.subtitle!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF75809C),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
