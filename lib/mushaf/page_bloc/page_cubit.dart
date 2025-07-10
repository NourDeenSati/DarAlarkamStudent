import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/api_service.dart';
import '../core/data.dart';
import '../modules/line.dart';
import '../modules/note.dart';
import 'package:quran/quran.dart' as quran;
import 'page_states.dart';

class PageCubit extends Cubit<PageStates> {
  int pageNumber = 3;
  List<Line> pageLines = [];
  int startPage = -1;

  List<Note> notes = [];
  String studentName = "";

  final String studentId;
  var endPage = -1;
  final Set<String> _highlightedWords = {};


  PageCubit(Function() initialState, this.studentId) : super(initialState()) {
    if (initialState() is InitialMultiPageState) {
      pageNumber = (initialState() as InitialMultiPageState).startPage;
      endPage = (initialState() as InitialMultiPageState).endPage;
      startPage = pageNumber;
      initialMultiPage();

    } else if (initialState() is InitialOnePageState) {
      initialOnePage();

      pageNumber = (initialState() as InitialOnePageState).pageNumber;
    }
  }

  Future<void> initialOnePage() async {
    emit(LoadingPageState());

    var response = await ApiService.getOneDetails(
      pageNumber: pageNumber,
      studentId: studentId,
    );
    notes = Note.getListFromObject(response);

    getPageData();

    try {

      emit(SuccessPageState());
    } catch (e) {
      emit(FailToStartPage(error: e.toString()));
    }
  }
  Future<void> initialMultiPage() async {
    emit(LoadingPageState());

    var response = await ApiService.getMultiDetails(
      startPage:startPage,
      endPage:endPage,
      saberId: studentId,
    );
    notes = Note.getListFromObject(response);
    getPageData();

    try {

      emit(SuccessPageState());
    } catch (e) {
      emit(FailToStartPage(error: e.toString()));
    }
  }

  void getPageData() {
    int start = -1;
    int end = -1;
    pageLines = [];
    if (pageNumber == 1) {
      start = 0;
      end = 8;
    } else if (pageNumber == 2) {
      start = 8;
      end = 16;
    } else {
      start = 16 + 15 * (pageNumber - 3);
      end = 16 + 15 * (pageNumber - 3) + 15;
    }
    List<String> lines = mushafLines.sublist(start, end);
    int lineNumber = 0;
    for (var line in lines) {
      lineNumber++;
      pageLines.add(
        Line(text: line, pageNumber: pageNumber, lineNumber: lineNumber),
      );
    }
  }

  bool isHighlighted(int lineNumber, int wordOrder) {
    return _highlightedWords.contains('$lineNumber-$wordOrder');
  }

  String surNames() {
    if (pageNumber > 604 || pageNumber < 1) return "";
    List pagesData = quran.getPageData(pageNumber);

    String text = "";
    for (var pageD in pagesData) {
      text += "${quran.getSurahNameArabic(pageD["surah"])},";
    }
    return text.substring(0, text.length - 1);
  }

  void changeToPage({required int number}) {
    pageNumber = startPage + number;
    getPageData();
    emit(SuccessPageState());
  }

  String tajweedNotes() {
    return notes
        .where((note) => note.falseType == FalseTypes.tajweed)
        .length
        .toString();
  }

  String tashkeelNotes() {
    return notes
        .where((note) => note.falseType == FalseTypes.tashkeel)
        .length
        .toString();
  }

  String hafezNotes() {
    return notes
        .where((note) => note.falseType == FalseTypes.hafez)
        .length
        .toString();
  }

  List<Color> containerColor({
    required int wordOrder,
    required int lineNumber,
    required Color defaultColor,
  }) {
    if (notes
        .where(
          (note) =>
              (note.lineNumber == lineNumber &&
                  note.wordNumber == wordOrder &&
                  note.pageNumber == pageNumber),
        )
        .isEmpty) {
      return [defaultColor, defaultColor];
    }
    List<Note> currentNotes =
        notes
            .where(
              (note) =>
                  (note.lineNumber == lineNumber &&
                      note.wordNumber == wordOrder &&
                      note.pageNumber == pageNumber),
            )
            .toList();
    List<Color> colors = [];
    for (var element in currentNotes) {
      if (element.falseType == FalseTypes.hafez) {
        colors.add(Colors.red[100]!);
      } else if (element.falseType == FalseTypes.tajweed) {
        colors.add(Colors.green[100]!);
      } else {
        colors.add(Colors.black12);
      }
    }
    if (colors.length < 2) colors.add(colors[0]);
    return colors;
  }
}
