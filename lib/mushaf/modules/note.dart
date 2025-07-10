class Note {
  final int pageNumber;
  final int lineNumber;
  final int wordNumber;
  final String falseType;

  Note({
    required this.pageNumber,
    required this.lineNumber,
    required this.wordNumber,
    required this.falseType,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "p:$pageNumber,l:$lineNumber,w:$wordNumber,f:$falseType";
  }

  Map<String, int> getObject(bool isOneTest) {
    return {
      "mistake_id": FalseTypes.getID(falseType, isOneTest),
      "page_number": pageNumber,
      "line_number": lineNumber,
      "word_number": wordNumber,
    };
  }

  static List getObjectList(List<Note> notes, bool isOneTest) {
    return List.generate(
      notes.length,
      (index) => notes[index].getObject(isOneTest),
    );
  }

  static List<Note> getListFromObject(List mistakes) {
    List<Note> values = [];
    for (var mistake in mistakes) {
      values.add(
        Note(
          pageNumber: mistake["page_number"],
          lineNumber: mistake["line_number"],
          wordNumber: mistake["word_number"],
          falseType: mistake["mistake"],
        ),
      );
    }
    return values;
  }
}

class FalseTypes {
  static const String tashkeel = "تشكيل";
  static const String hafez = "حفظ";
  static const String tajweed = "تجويد";



  static getID(String falseType, bool isOneTest) {
    switch (falseType) {
      case tashkeel:
        return isOneTest ? 4 : 1;
      case tajweed:
        return isOneTest ? 6 : 3;
      case hafez:
        return isOneTest ? 5 : 2;
    }
  }
}
