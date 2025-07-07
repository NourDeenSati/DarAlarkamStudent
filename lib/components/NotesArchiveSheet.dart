// components/NotesArchiveSheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohud/controllers/ArchiveController.dart';
import 'package:shimmer/shimmer.dart';

class NotesArchiveSheet extends StatefulWidget {
  const NotesArchiveSheet({Key? key}) : super(key: key);

  @override
  _NotesArchiveSheetState createState() => _NotesArchiveSheetState();
}

class _NotesArchiveSheetState extends State<NotesArchiveSheet> {
  late final StudentArchiveController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<StudentArchiveController>();
    // طباعة للتأكد من استدعاء initState
    print('📝 NotesArchiveSheet.initState - fetching notes');
    ctrl.fetchNotes().then((_) {
      print('📝 fetchNotes completed, got ${ctrl.notes.length} items');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        // أثناء التحميل
        if (ctrl.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder:
                    (_, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 150, height: 16, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(width: 100, height: 14, color: Colors.white),
                      ],
                    ),
              ),
            ),
          );
        }

        // انتهاء التحميل
        if (ctrl.notes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا توجد ملاحظات')),
          );
        }

        // عرض البيانات الحقيقية
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                'أرشيف الملاحظات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                
              ),
              const Divider(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.notes.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final note = ctrl.notes[i];
                  return ListTile(
                    leading: Icon(
                      note.type == 'إيجابية'
                          ? Icons.thumb_up
                          : Icons.thumb_down,
                      color: note.type == 'إيجابية' ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      '${note.byName} (${note.value ?? 0})',
                    ), // ← نستخدم 0 كقيمة افتراضية
                    subtitle: Text(
                      '${note.type} \n'
                      '${note.updatedAt.year}-'
                      '${note.updatedAt.month.toString().padLeft(2, '0')}-'
                      '${note.updatedAt.day.toString().padLeft(2, '0')}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}
