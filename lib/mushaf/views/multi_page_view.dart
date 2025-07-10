import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../components/mushaf_app_bar.dart';
import '../components/mushaf_page.dart';
import '../components/operator_button.dart';
import '../components/waiting_widget.dart';
import '../core/functions.dart';
import '../page_bloc/page_cubit.dart';
import '../page_bloc/page_states.dart';

class MultiPageView extends StatelessWidget {
  const MultiPageView({
    super.key,
    required this.startPage,
    required this.endPage,
    required this.studentId,
  });

  final int startPage;
  final int endPage;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();

    return BlocProvider(
      create: (BuildContext context) {
        return PageCubit(
          () => InitialMultiPageState(startPage: startPage, endPage: endPage),
          studentId,
        );
      },
      child: BlocListener<PageCubit,PageStates>(
        listener: (BuildContext context, state) {
          if (state is FailToStartPage) {
            Navigator.pop(context);

            Get.snackbar(
              "خطأ",
              state.error,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.errorContainer,
              colorText: Get.theme.colorScheme.onErrorContainer,
            );
          }
          if (state is FailurePageState) {
            Get.snackbar(
              "خطأ",
              state.error,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.errorContainer,
              colorText: Get.theme.colorScheme.onErrorContainer,
            );
          }
          if (state is CompletedListenState) {
            Navigator.pop(context);
            Get.snackbar(
              "تم حفظ التسميع",
              "التقييم ${state.result}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.onPrimary,
              colorText: Get.theme.colorScheme.onPrimaryContainer,
            );
          }
        },
        child: Scaffold(
          appBar: mushafAppBar(context: context),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width,
                  child: BlocBuilder<PageCubit, PageStates>(
                    builder: (context, state) {
                      if (state is LoadingPageState) {
                        return WaitingWidget();
                      }
                      return PageView.builder(
                        reverse: false,
                        onPageChanged: (page) {
                          context.read<PageCubit>().changeToPage(number: page);
                        },
                        controller: controller,
                        itemBuilder: (context, snapshot) {
                          return MushafPage();
                        },
                        itemCount: (endPage + 1) - startPage,
                      );
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                BlocBuilder<PageCubit, PageStates>(
                  builder: (BuildContext context, state) {
                    return OperatorButton(
                      onPressed: () {
                        AppFunctions.showQuranDialog(
                          context,
                          "إحصائيات الصفحة",
                              () {

                          },
                          context.read<PageCubit>().tajweedNotes(),
                          context.read<PageCubit>().tashkeelNotes(),

                          context.read<PageCubit>().hafezNotes(),
                        );
                      },
                      text: "إحصائيات",

                      enable: true,
                    );
                  },
                  buildWhen: (p, c) => false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
