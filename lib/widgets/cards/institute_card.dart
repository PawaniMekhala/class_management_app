import 'package:flutter/material.dart';

import '../../models/institute_model.dart';

class InstituteCard extends StatelessWidget {
  final InstituteModel institute;
  final VoidCallback onTap;

  const InstituteCard({
    super.key,
    required this.institute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              // Institute icon
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6EBFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Color(0xFF354A92),
                  size: 22,
                ),
              ),

              const SizedBox(width: 10),

              // Institute information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      institute.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF293B78),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${institute.role} · ${institute.company}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF75809C),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right arrow
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF3D5AFE),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
