import 'package:flutter/material.dart';

import '../../models/dashboard_stat_model.dart';
import '../cards/dashboard_stat_card.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final List<DashboardStatModel> stats;
  final Function(DashboardStatModel)? onCardTap;

  const DashboardSection({
    super.key,
    required this.title,
    required this.stats,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF526184),
          ),
        ),

        const SizedBox(height: 8),

        // Two-column statistic cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          itemCount: stats.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 110,
          ),

          itemBuilder: (context, index) {
            final stat = stats[index];

            return DashboardStatCard(
              stat: stat,
              onTap: onCardTap == null ? null : () => onCardTap!(stat),
            );
          },
        ),
      ],
    );
  }
}
