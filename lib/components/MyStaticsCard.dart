import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ohud/controllers/StudentStatsController.dart';

class MotivationalStatsSection extends StatelessWidget {
  const MotivationalStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentStatsController controller = Get.find();

    return Obx(() {
      if (controller.isLoading.value) {
        // ===== Shimmer placeholders =====
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان وهمي
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(width: 200, height: 24, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(2, (_) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 230,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return const Center(child: Text('لا توجد بيانات متاحة.'));
      }

      // ===== العرض الحقيقي =====
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👇 مخطط دائري تفاعلي لعرض النقاط
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                animation: true,
                percent:
                    (int.tryParse(stats.points) ?? 0) /
                    500.0, // على فرض أن الحد الأقصى 200
              
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stats.points} نقطة',
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'استعن بالله ولا تعجز  ',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ],
                ),
                
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.amber.shade800,
                backgroundColor: Colors.amber.shade100,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'أداؤك هذا الأسبوع',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MotivationalCard(
                    color:
                        stats.improvementPercent >= 0
                            ? Colors.teal
                            : Colors.redAccent,
                    icon:
                        stats.improvementPercent >= 0
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
                    title: 'نقاط الأسبوع',
                    value: '${stats.gainThisWeek} نقطة',
                    subtitle: ' الأسبوع السابق: ${stats.gainLastWeek}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MotivationalCard(
                    color: Colors.teal,
                    icon: LucideIcons.award,
                    title: 'الترتيب الحالي',
                    value: 'حلقة: ${stats.circleNow}  مسجد: ${stats.mosqueNow}',
                    subtitle:
                        'الحلقة سابقًا: ${stats.circlePrev}\nالمسجد سابقًا: ${stats.mosquePrev}',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _MotivationalCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _MotivationalCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
