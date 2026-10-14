import 'package:flutter/material.dart';

import '../../models/notice_model.dart';

class NoticeCard extends StatefulWidget {
  final NoticeModel notice;
  final VoidCallback onTap;

  const NoticeCard({super.key, required this.notice, required this.onTap});

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  bool _isRead = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAE4E4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isRead = true;
          });

          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Show information icon only if unread
              if (!_isRead) ...[
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF5A623),
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],

              // Notice message
              Expanded(
                child: Text(
                  widget.notice.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF44547F),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Right arrow
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF3D5AFE),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
