abstract class PageStates {}

class InitialOnePageState extends PageStates {
  final int pageNumber;

  InitialOnePageState({required this.pageNumber});
}

class InitialMultiPageState extends PageStates {
  final int startPage;

  final int endPage;

  InitialMultiPageState( {required this.endPage,required this.startPage});
}

class LoadingPageState extends PageStates {}
class ChangeListenState extends PageStates{}

class CompletedListenState extends PageStates {
  final String result;

  CompletedListenState(this.result);
}

class SuccessPageState extends PageStates {}
class FailToStartPage extends PageStates {
  final String error;

  FailToStartPage({required this.error});

}



class FailurePageState extends PageStates {
  final String error;

  FailurePageState({required this.error});
}

class WordHighlightPageState extends PageStates {
  final Set<String> highlightedWords;

  WordHighlightPageState({required this.highlightedWords});
}
