import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ohud/components/MyAddContainer.dart';
import 'package:ohud/components/MyCarousel.dart';
import 'package:ohud/components/MyNavigationDestination.dart';
import 'package:ohud/components/MyStaticsCard.dart';
import 'package:ohud/controllers/ArchiveController.dart';
import 'package:ohud/controllers/HomeController.dart';
import 'package:ohud/controllers/LogOutController.dart';
import 'package:ohud/controllers/StudentStatsController.dart';
import 'package:ohud/controllers/carousel_controller.dart' as my_carousel;
import 'package:ohud/screens/SavePlane.dart';
import 'package:ohud/screens/SignInScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ohud/components/RecitationArchiveSheet.dart';
import 'package:ohud/components/AttendanceArchiveSheet.dart';
import 'package:ohud/components/NotesArchiveSheet.dart';
import 'package:ohud/components/SabrsArchiveSheet.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({Key? key}) : super(key: key) {
    // تأكد من تسجيل HomeController في الـ GetX
    Get.put(HomeController());
  }

  final LogoutController logoutController = Get.put(LogoutController());
  final my_carousel.MyCarouselController MycarouselController = Get.put(
    my_carousel.MyCarouselController(),
  );
  final PageController pageController = PageController(viewportFraction: 0.7);
Future<void> logout() async {
  await logoutController.logout();

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('user_name');
  await prefs.remove('circle_id');
  await prefs.remove('user_id');

  // حذف HomeController وغيره إن وجد
  Get.delete<HomeController>();

  // أو حذف كل شيء مرة واحدة
  // Get.reset();

  Get.offAll(() => SigninScreen());
}

  @override
  Widget build(BuildContext context) {
    // خذ الـ HomeController المسجّل في GetX
    final HomeController homeController = Get.find();

    return Scaffold(
      appBar: AppBar(
        // ننقل الـ Row هنا إلى title
        title: Obx(
          () => Row(
            children: [
              Text(
                'مرحباً بك ${homeController.userName.value} !',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        // الـ actions تضم أيقونة تسجيل الخروج فقط
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout, color: Color(0XFF049977)),
            onPressed: logout,
          ),
        ],
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _MainContent(),
            const SaveplaneScreen(),
            const SaveplaneScreen(),
            const SaveplaneScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final selectedIndex = controller.currentIndex.value;
        return NavigationBar(
          height: 70,
          selectedIndex: selectedIndex,
          onDestinationSelected: controller.changePage,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          backgroundColor: Colors.white,
          indicatorShape: const RoundedRectangleBorder(side: BorderSide.none),
          indicatorColor: Colors.transparent,
          destinations: [
            MyNavigationDestination(
              icon: Iconsax.home,
              label: 'الرئيسية',
              index: 0,
              selectedIndex: selectedIndex,
            ),
            MyNavigationDestination(
              icon: Iconsax.cup,
              label: 'مخطط الحفظ',
              index: 1,
              selectedIndex: selectedIndex,
            ),
            MyNavigationDestination(
              icon: Iconsax.shop,
              label: 'متجر النقاط',
              index: 2,
              selectedIndex: selectedIndex,
            ),
            MyNavigationDestination(
              icon: Iconsax.eye,
              label: 'متابعة النفس',
              index: 3,
              selectedIndex: selectedIndex,
            ),
          ],
        );
      }),
    );
  }
}

class _MainContent extends StatelessWidget {
  // هنا نعرِّف الكونترولر كحقل في الكلاس
  final StudentStatsController studentController = Get.put(
    StudentStatsController(),
    permanent: true,
  );
  final StudentArchiveController archiveCtrl = Get.put(
    StudentArchiveController(),
    permanent: true,
  );
  final LogoutController logoutController = Get.put(LogoutController());
  final HomeController homeController = Get.find<HomeController>();

  _MainContent() {
    // نستدعي بيانات الإحصائيات مرة واحدة عند إنشاء الودجت
    Future.delayed(Duration.zero, () {
      studentController.loadData();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await studentController.loadData();
        await archiveCtrl.fetchAttendance();
        await archiveCtrl.fetchNotes(); // مثلاً لجلب كل أنواع الأرشيف
        await archiveCtrl.fetchRecitations();
        await archiveCtrl.fetchSabrs();
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // مهم لتفعيل السحب حتى لو المحتوى قصير
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 30),
              // const MyCarousel(),
              const SizedBox(height: 40),
              const MotivationalStatsSection(),
              const SizedBox(height: 40),
              Row(
                children: const [
                  Icon(Iconsax.add_square, color: Color(0XFF049977)),
                  SizedBox(width: 15),
                  Text(
                    'الأرشيف :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // قرآن
                  MyAddContainer(
                    text: 'قرآن',
                    iconData: Iconsax.book,
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: true,
                        enableDrag: true,
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => RecitationArchiveSheet(),
                      );
                    },
                  ),
                  // حضور
                  MyAddContainer(
                    text: 'حضور',
                    iconData: Iconsax.card,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => AttendanceArchiveSheet(),
                      );
                    },
                  ),
                  // ملاحظات
                  MyAddContainer(
                    text: 'ملاحظات',
                    iconData: Iconsax.note_text,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => NotesArchiveSheet(),
                      );
                    },
                  ),
                  // السبر
                  MyAddContainer(
                    text: 'السبر',
                    iconData: Icons.quiz_outlined,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => const SabrsArchiveSheet(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
