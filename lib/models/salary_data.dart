/// StudyValue - 偏差値帯別年収データモデル
/// 大学別の年収データを管理

import 'package:hive/hive.dart';

part 'salary_data.g.dart';

@HiveType(typeId: 2)
class SalaryData extends HiveObject {
  @HiveField(0)
  String universityName;

  @HiveField(1)
  double averageAnnualSalary;

  @HiveField(2)
  int deviationValue;

  @HiveField(3)
  String category; // 国立、私立、など

  @HiveField(4)
  DateTime lastUpdated;

  SalaryData({
    required this.universityName,
    required this.averageAnnualSalary,
    required this.deviationValue,
    required this.category,
    required this.lastUpdated,
  });

  SalaryData copyWith({
    String? universityName,
    double? averageAnnualSalary,
    int? deviationValue,
    String? category,
    DateTime? lastUpdated,
  }) {
    return SalaryData(
      universityName: universityName ?? this.universityName,
      averageAnnualSalary: averageAnnualSalary ?? this.averageAnnualSalary,
      deviationValue: deviationValue ?? this.deviationValue,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'SalaryData(university: $universityName, salary: $averageAnnualSalary, deviation: $deviationValue)';
  }
}