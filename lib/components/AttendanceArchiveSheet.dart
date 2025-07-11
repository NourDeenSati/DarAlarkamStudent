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
    if (!ctrl.isLoading.value && (ctrl.attendance.value == null)) {
      ctrl.fetchAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 120, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  ...List.generate(
                    4,
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

        if (ctrl.attendance.value == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا توجد بيانات حضور')),
          );
        }

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

                // إحصائيات الحضور المحسّنة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إحصائيات الحضور',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Builder(builder: (_) {
                        final totalDays = statItems.fold<int>(0, (sum, e) => sum + e.value.count);
                        final attendedDays = (model.stats['حضور']?.count ?? 0) +
                            (model.stats['تأخير']?.count ?? 0);
                        final presentRatio =
                            totalDays == 0 ? 0 : (attendedDays / totalDays * 100);

                        return Card(
                          color: Colors.teal[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('نسبة الحضور الإجمالية:',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${presentRatio.toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 16, color: Colors.teal)),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      ...statItems.map((e) {
                        Color color;
                        switch (e.key) {
                          case 'حضور':
                            color = Colors.green;
                            break;
                          case 'غياب مبرر':
                            color = Colors.orange;
                            break;
                          case 'غياب غير مبرر':
                            color = Colors.red;
                            break;
                          case 'تأخر':
                            color = Colors.amber;
                            break;
                          default:
                            color = Colors.grey;
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: TextStyle(color: color)),
                              Text('${e.value.count} (${e.value.ratio.toStringAsFixed(1)}%)',
                                  style: TextStyle(color: color)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // تفاصيل الأيام على شكل جدول
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'تفاصيل الأيام',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
                          itemBuilder: (_, i) {
                            final rec = records[i];
                            Color color;
                            switch (rec.attendanceType) {
                              case 'حضور':
                                color = Colors.green;
                                break;
                              case 'غياب مبرر':
                                color = Colors.orange;
                                break;
                              case 'غياب غير مبرر':
                                color = Colors.red;
                                break;
                              case 'تأخر':
                                color = Colors.amber;
                                break;
                              default:
                                color = Colors.grey;
                            }

                            final formattedDate =
                                '${rec.date.year}-${rec.date.month.toString().padLeft(2, '0')}-${rec.date.day.toString().padLeft(2, '0')}';

                            return ListTile(
                              leading: Icon(Icons.circle, size: 12, color: color),
                              title: Text(formattedDate),
                              trailing: Text(
                                rec.attendanceType,
                                style: TextStyle(color: color, fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
