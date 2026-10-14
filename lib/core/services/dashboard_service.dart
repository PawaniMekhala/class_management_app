import 'package:flutter/material.dart';

import '../../models/dashboard_stat_model.dart';
import '../../models/notice_model.dart';

class DashboardService {
  // Temporary data. Replace with API calls later.

  Future<List<NoticeModel>> getNotices(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      const NoticeModel(
        id: 1,
        type: 'refund',
        message: '1 refund / adjustment request(s) waiting for approval',
        count: 1,
      ),
      const NoticeModel(
        id: 2,
        type: 'tute_reissue',
        message: '2 tute reissue request(s) waiting for approval',
        count: 2,
      ),
      const NoticeModel(
        id: 3,
        type: 'student_profile',
        message: '1 student profile update(s) waiting for approval',
        count: 1,
      ),
    ];
  }

  Future<Map<String, List<DashboardStatModel>>> getDashboardStats(
    int instituteId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'Totals': [
        const DashboardStatModel(
          title: 'Active students',
          value: '12',
          subtitle: '0 new this month',
        ),
        const DashboardStatModel(title: 'Teachers', value: '6'),
        const DashboardStatModel(
          title: 'Active classes',
          value: '12',
          subtitle: '22 enrolled',
        ),
        const DashboardStatModel(title: 'Enrollments this month', value: '1'),
      ],

      'Today': [
        const DashboardStatModel(
          title: 'Classes today',
          value: '1',
          subtitle: '2 running now',
        ),
        const DashboardStatModel(
          title: 'In class now',
          value: '0',
          subtitle: '0 checked in today',
        ),
      ],

      'Attendance': [
        const DashboardStatModel(
          title: 'Attendance (7 days)',
          value: '92%',
          subtitle: '2 absences',
          valueColor: Color(0xFF4CAF50),
        ),
        const DashboardStatModel(
          title: 'Unpaid gate entries',
          value: '22',
          valueColor: Color(0xFFF59E0B),
        ),
      ],

      'Money': [
        const DashboardStatModel(
          title: 'Collected today',
          value: 'Rs. 0',
          subtitle: '0 receipts',
        ),
        const DashboardStatModel(
          title: 'Collected this month',
          value: 'Rs. 25,800',
          subtitle: 'after Rs. 1,000 refunds',
          valueColor: Color(0xFF4CAF50),
        ),
        const DashboardStatModel(
          title: 'Outstanding',
          value: 'Rs. 78,300',
          valueColor: Color(0xFFF59E0B),
        ),
        const DashboardStatModel(
          title: 'Overdue',
          value: 'Rs. 12,000',
          subtitle: '5 students',
          valueColor: Color(0xFFEF4444),
        ),
      ],

      'Tutes': [
        const DashboardStatModel(
          title: 'Tutes to hand out',
          value: '25',
          // subtitle: '2 running now'
          valueColor: Color(0xFFF59E0B),
        ),
      ],
    };
  }
}
