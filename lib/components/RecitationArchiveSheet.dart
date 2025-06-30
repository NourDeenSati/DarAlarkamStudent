// components/RecitationArchiveSheet.dart

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
        // 1. عرض Shimmer أثناء التحميل
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
                  Container(width: 140, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  // 5 صفوف وهمية
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        // 2. بعد الانتهاء: فلترة الصفحات المسموعة
        final heard = ctrl.recitations.where((r) => r.recited).toList();

        // 3. إذا لا توجد صفحات مسموعة
        if (heard.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا توجد صفحات مسمعة')),
          );
        }

        // 4. المحتوى الحقيقي داخل ScrollView لتجنّب overflow
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
                'أرشيف التسميع',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              // عرض الصفحات المسموعة
              ...heard.map((item) {
                return ListTile(
                  leading: Icon(Icons.touch_app_sharp, color: Colors.green),
                  title: Text('صفحة ${item.page}'),
                  subtitle: Text(item.result ?? 'لم يُسجل نتيجة'),
                  onTap: () {
                    
                  },
                  
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
