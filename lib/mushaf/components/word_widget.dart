import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modules/note.dart';
import '../page_bloc/page_cubit.dart';
import '../page_bloc/page_states.dart';

class WordWidget extends StatelessWidget {
  String word;
  final bool canPress;
  final int wordOrder;
  final int lineNumber;

  WordWidget({
    super.key,
    required this.word,
    required this.canPress,
    required this.wordOrder,
    required this.lineNumber,
  });



  @override
  Widget build(BuildContext context) {
    String splitter = containNumber();

    return BlocBuilder<PageCubit, PageStates>(
      buildWhen: (previous, current) => current is WordHighlightPageState,
      builder: (context, state) {
        bool isHighlighted = false;
        if (state is WordHighlightPageState) {
          isHighlighted = state.highlightedWords.contains(
            '$lineNumber-$wordOrder',
          );
        }
        Color defaultColor =
            isHighlighted ? Colors.yellowAccent : Colors.transparent;

        List<Color> gradientColors = context.read<PageCubit>().containerColor(
          wordOrder: wordOrder,
          lineNumber: lineNumber,
          defaultColor: defaultColor,
        );

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                word,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: "uthmani", fontSize: 18),
              ),
            ),
            splitter.isNotEmpty
                ? Text(
                  splitter,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: "uthmani", fontSize: 18),
                )
                : SizedBox(),
          ],
        );
      },
    );
  }

  String containNumber() {
    List numbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String num = "";
    Map<int, String> nums = {};
    bool added = true;

    while (added) {
      added = false;
      for (String number in numbers) {
        int ind = -1;
        word.characters.toList().asMap().forEach((k, v) {
          if (v == number && !nums.containsKey(k)) {
            ind = k;
            added = true;
            return;
          }
        });
        if (ind != -1) {
          nums.addAll({ind: number});
          break;
        }
      }
    }
    if (nums.isNotEmpty) {
      List<int> keys = nums.keys.toList();
      keys.sort();
      for (var key in keys) {
        num += nums[key] ?? "";
      }
      word = word.substring(0, word.length - keys.length - 1);
    }

    return num;
  }
}
