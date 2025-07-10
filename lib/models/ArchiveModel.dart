// models/student_archive_models.dart

class NoteModel {
  final int id;
  final String byName;
  final String type;
  final String status;
  final int? value; // ← نجعله قابلًا لأن يكون null
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.byName,
    required this.type,
    required this.status,
    required this.value,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int,
      byName: json['by_name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      value: json['value'] != null ? (json['value'] as num).toInt() : null,
      // ← إذا كان null اتركه null
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class AttendanceStat {
  final int count;
  final double ratio;

  AttendanceStat({required this.count, required this.ratio});

  factory AttendanceStat.fromJson(Map<String, dynamic> json) {
    return AttendanceStat(
      count: json['count'],
      ratio: (json['ratio'] as num).toDouble(),
    );
  }
}

class AttendanceModel {
  final Map<String, AttendanceStat> stats;
  final List<AttendanceRecord> list;

  AttendanceModel({required this.stats, required this.list});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>;
    final stats = statsJson.map(
      (key, val) =>
          MapEntry(key, AttendanceStat.fromJson(val as Map<String, dynamic>)),
    );

    final listJson =
        (json['list'] as List)
            .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
            .toList();

    return AttendanceModel(stats: stats, list: listJson);
  }
}

class AttendanceRecord {
  final DateTime date;
  final String attendanceType;

  AttendanceRecord({required this.date, required this.attendanceType});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      attendanceType: json['attendanceType'],
    );
  }
}

class RecitationHistoryRecord {
  final int page;
  final int points;

  final String? result;
  final int id;

  RecitationHistoryRecord({
    required this.page,
    this.result,
    required this.points,
    required this.id,
  });

  factory RecitationHistoryRecord.fromJson(Map<String, dynamic> json) {
    return RecitationHistoryRecord(
      page: json['page'],
      result: json['result'],
      points: json["points"],
      id: json["id"],
    );
  }
}

class SabrHistoryRecord {
  final int id;
  final List<int> juzs;
  final int points;
  final String? result;

  SabrHistoryRecord({
    required this.id,
    required this.juzs,
    required this.points,
    required this.result,
  });

  factory SabrHistoryRecord.fromJson(Map<String, dynamic> json) {
    return SabrHistoryRecord(
      result: json['result'],
      id: json["id"],
      juzs: json["juz"].cast<int>(),
      points: json["points"],
    );
  }

  startPage() {
    int start = juzs.first;
    return (start - 1) * 20 + (start > 1 ? 2 : 1);
  }

  endPage() {
    int start = juzs.first;
    int end = juzs.last;

    return end * 20 + (start == 30 ? 4 : 1);
  }
}
