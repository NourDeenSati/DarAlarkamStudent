// components/SabrsArchiveSheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohud/controllers/ArchiveController.dart';
import 'package:ohud/mushaf/views/multi_page_view.dart';
import 'package:shimmer/shimmer.dart';
class SabrsArchiveSheet extends StatefulWidget {
  const SabrsArchiveSheet({Key? key}) : super(key: key);

  @override
  _SabrsArchiveSheetState createState() => _SabrsArchiveSheetState();
}

class _SabrsArchiveSheetState extends State<SabrsArchiveSheet> {
  late final StudentArchiveController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<StudentArchiveController>();
    if (!ctrl.isLoading.value && ctrl.sabrs.isEmpty) {
      ctrl.fetchSabrs();
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        // بينما التحميل جارٍ
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
                  // خمسة أسطر وهمية
                  ...List.generate(5, (_) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(width: 24, height: 24, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Container(height: 16, color: Colors.white)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        }

        // بعد الانتهاء من التحميل
        final sabrs = ctrl.sabrs;
        if (sabrs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا توجد نتائج سبر')),
          );
        }

        // المحتوى الحقيقي: نلفّه بـ SingleChildScrollView لتجنّب overflow
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'أرشيف السبر',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              // عرض فقط الأجزاء المسبرة
              ...sabrs.map((s) {
                return GestureDetector(
                  onTap: (){
                    Get.to(MultiPageView(startPage: s.startPage(), endPage: s.endPage(), studentId: s.id.toString()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('${s.juzs.length>1?"أجزاء":"جزء"} ${s.juzs}'),
                    subtitle: Text(s.result ?? 'لم يُسجل نتيجة'),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}
