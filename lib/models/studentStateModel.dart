class StudentStatsModel {
  final int gainThisWeek;
  final int gainLastWeek;
  final double improvementPercent;
  final int circleNow;
  final int circlePrev;
  final int mosqueNow;
  final int mosquePrev;

  // بيانات جديدة من ملف الطالب
  final int id;
  final String name;
  final String points;
  final String level;
  final String courseName;

  StudentStatsModel({
    required this.gainThisWeek,
    required this.gainLastWeek,
    required this.improvementPercent,
    required this.circleNow,
    required this.circlePrev,
    required this.mosqueNow,
    required this.mosquePrev,
    required this.id,
    required this.name,
    required this.points,
    required this.level,
    required this.courseName,
  });

  factory StudentStatsModel.fromResponses({
    required Map<String, dynamic> weeklyJson,
    required Map<String, dynamic> rankingsJson,
    required Map<String, dynamic> profileJson,
  }) {
    return StudentStatsModel(
      gainThisWeek: (weeklyJson['gain_this_week'] as num).toInt(),
      gainLastWeek: (weeklyJson['gain_last_week'] as num).toInt(),
      improvementPercent: (weeklyJson['improvementPercent'] as num).toDouble(),
      circleNow: (rankingsJson['circle']['now'] as num).toInt(),
      circlePrev: (rankingsJson['circle']['prev'] as num).toInt(),
      mosqueNow: (rankingsJson['mosque']['now'] as num).toInt(),
      mosquePrev: (rankingsJson['mosque']['prev'] as num).toInt(),
      id: profileJson['id'],
      name: profileJson['name'],
      points: profileJson['points'],
      level: profileJson['level'],
      courseName: profileJson['course_name'],
    );
  }
}
