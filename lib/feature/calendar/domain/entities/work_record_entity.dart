import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WorkType {
  work, // 일반 근무
  vacation, // 연차
  holiday, // 공휴일 or 사용자 지정 휴일
}

class WorkRecordEntity extends Equatable {
  const WorkRecordEntity({
    required this.id,
    required this.date,
    required this.type,
    this.workMinutes,
    this.startTime,
    this.endTime,
    this.memo,
  });

  final String id;
  final DateTime date;
  final WorkType type;
  final int? workMinutes; // WorkType.work 에서만 사용. 총 근무시간(분 단위)
  final TimeOfDay? startTime; // WorkType.work 에서만 사용
  final TimeOfDay? endTime; // WorkType.work 에서만 사용
  final String? memo; // 선택 입력 메모

  Duration get workedDuration {
    return switch (type) {
      WorkType.work => Duration(minutes: workMinutes ?? 0),
      WorkType.vacation => Duration.zero,
      WorkType.holiday => Duration.zero,
    };
  }

  bool get hasMemo => memo != null && memo!.isNotEmpty;

  WorkRecordEntity copyWith({
    String? id,
    DateTime? date,
    WorkType? type,
    int? workMinutes,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? memo,
  }) {
    return WorkRecordEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      workMinutes: workMinutes ?? this.workMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      memo: memo ?? this.memo,
    );
  }

  @override
  List<Object?> get props => [id, date, type, workMinutes, startTime, endTime, memo];
}
