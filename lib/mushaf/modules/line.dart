class Line {
  List<String> words = [];
    bool isCenter=false;
  late final LineTypes lineType;
  final int pageNumber;
  final int lineNumber;

  Line({
    required String text,
    required this.pageNumber,
    required this.lineNumber,
  }) {
    words = text.split(' ');
    if ((words.length == 2||words.length == 3) && words.contains("سُورَةُ")) {
      words=[text];
      lineType = LineTypes.surahName;
      isCenter = true;
    } else if (words.length == 4 &&(words.contains("بِسۡمِ ")||words.contains("ٱللَّهِ")) ) {
      lineType = LineTypes.basmallah;


      isCenter = true;
    } else {
      lineType = LineTypes.normalLine;
    }
    if (pageNumber >= 601 || pageNumber <= 2) {
      isCenter = true;
    }
  }
  @override
  String toString() {
    // TODO: implement toString
    return "{center:$isCenter}";
  }

  isShort() {
    int a= 0;
    for (var word in words) {
      a+=word.length;
    }
    print(a);
    print(a<50?30:0);
    return a<47;

  }
}

enum LineTypes { surahName, basmallah, normalLine }
