class BMI {
  final String? bmiId;
  final String result;
  final DateTime dateCreate;

  BMI({this.bmiId, required this.result, required this.dateCreate});

  BMI copy({String? bmiId, String? result, DateTime? dateCreate}) {
    return BMI(
        bmiId: bmiId ?? this.bmiId,
        result: result ?? this.result,
        dateCreate: dateCreate ?? this.dateCreate);
  }

  @override
  String toString() {
    return "BMI($bmiId. $result, $dateCreate)";
  }

  Map<String, dynamic> toMap() {
    return {
      "result": result,
      "dateCreate": dateCreate.millisecondsSinceEpoch,
    };
  }

  static BMI fromMap(Map<String, dynamic> map) {
    return BMI(
      bmiId: map["bmiId"],
      result: map["result"],
      dateCreate: DateTime.fromMillisecondsSinceEpoch(map["dateCreate"]),
    );
  }
}
