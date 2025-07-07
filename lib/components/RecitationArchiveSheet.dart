import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohud/controllers/ArchiveController.dart';
import 'package:shimmer/shimmer.dart';

class RecitationArchiveSheet extends StatefulWidget {
  const RecitationArchiveSheet({Key? key}) : super(key: key);

  @override
  _RecitationArchiveSheetState createState() => _RecitationArchiveSheetState();
}

class _RecitationArchiveSheetState extends State<RecitationArchiveSheet> {
  late final StudentArchiveController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<StudentArchiveController>();

    if (!ctrl.isLoading.value && ctrl.recitations.isEmpty) {
      ctrl.fetchRecitations();
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
                  Container(width: 140, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  ...List.generate(
                    5,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(width: 24, height: 24, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(height: 16, color: Colors.white),
                          ),
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

        final heard = ctrl.recitations.where((r) => r.recited).toList();

        if (heard.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا توجد صفحات مسمعة')),
          );
        }

        // حساب نسب التقييمات
        final total = heard.length;
        final excellent = heard.where((e) => e.result == 'ممتاز').length;
        final verygood = heard.where((e) => e.result == 'جيد جداً' ).length;
        final good = heard.where((e) => e.result == 'جيد').length;
        final retry = heard.where((e) => e.result == 'إعادة').length;
        // final none =
        //     heard.where((e) => e.result == null || e.result == 'لا شيء').length;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'أرشيف التسميع',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // عرض النسب بشكل شريط تقدم
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLinearProgress(
                      'ممتاز',
                      excellent,
                      total,
                      Colors.green
                    ),
                    const SizedBox(height: 8),
                    _buildLinearProgress('جيد جداً', verygood , total, const Color.fromARGB(255, 152, 155, 0)),
                    const SizedBox(height: 8),

                    _buildLinearProgress('جيد', good, total, const Color.fromARGB(255, 255, 170, 0)),
                    const SizedBox(height: 8),
                    _buildLinearProgress(
                      'إعادة',
                      retry,
                      total,
                      const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // عرض الصفحات
              ...heard.map((item) {
                return ListTile(
                  leading: Icon(Icons.menu_book, color: Colors.teal),
                  title: Text('صفحة ${item.page}'),
                  subtitle: Text(item.result ?? 'لم يُسجل نتيجة'),
                  onTap: () {
                    // يمكن فتح التفاصيل هنا
                  },
                );
              }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLinearProgress(String label, int count, int total, Color color) {
  final percent = total == 0 ? 0.0 : count / total;
  final percentText = total == 0
      ? '0% (0 صفحة)'
      : '${(percent * 100).toStringAsFixed(0)}% ($count صفحة)';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          Text(
            percentText,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      const SizedBox(height: 4),
      LinearProgressIndicator(
        value: percent,
        color: color,
        backgroundColor: color.withOpacity(0.3),
        minHeight: 12,
      ),
    ],
  );
}
}
