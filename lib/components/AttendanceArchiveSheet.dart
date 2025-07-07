// components/AttendanceArchiveSheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohud/controllers/ArchiveController.dart';
import 'package:ohud/models/ArchiveModel.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceArchiveSheet extends StatefulWidget {
  const AttendanceArchiveSheet({Key? key}) : super(key: key);

  @override
  _AttendanceArchiveSheetState createState() => _AttendanceArchiveSheetState();
}

class _AttendanceArchiveSheetState extends State<AttendanceArchiveSheet> {
  late final StudentArchiveController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<StudentArchiveController>();
    // إذا لم يبدأ التحميل بعد
    if (!ctrl.isLoading.value && (ctrl.attendance.value == null)) {
      ctrl.fetchAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        // أثناء التحميل: Shimmer
        if (ctrl.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // عنوان وهمي
                  Container(width: 120, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  // إحصائيات وهمية (3 أسطر)
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // قائمة التواريخ وهمية
                  ...List.generate(
                    5,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 14,
                            color: Colors.white,
                          ),
                          const Spacer(),
                          Container(width: 60, height: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        // بعد التحميل: إذا لا بيانات
        if (ctrl.attendance.value == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا توجد بيانات حضور')),
          );
        }

        // البيانات الحقيقية
        final AttendanceModel model = ctrl.attendance.value!;
        final statItems = model.stats.entries.toList();
        final records = model.list;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'أرشيف الحضور',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),

                // إحصائيات مجمعة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children:
                        statItems.map((e) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key),
                              Text(
                                '${e.value.count} (${e.value.ratio.toStringAsFixed(1)}%)',
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),

                // قائمة بالتواريخ
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (_, i) {
                    final rec = records[i];
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 12,
                        color:
                            rec.attendanceType == 'حضور'
                                ? Colors.green
                                : rec.attendanceType == 'غياب مبرر'
                                ? Colors.orange
                                : rec.attendanceType == 'غياب غير مبرر'
                                ? Colors.red
                                : Colors.amber,
                      ),
                      title: Text(
                        '${rec.date.year}-${rec.date.month.toString().padLeft(2, '0')}-${rec.date.day.toString().padLeft(2, '0')}',
                      ),
                      subtitle: Text(rec.attendanceType),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}
