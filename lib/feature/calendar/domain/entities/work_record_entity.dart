import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WorkType {
  work,      // 일반 근무
  vacation,  // 연차
  holiday,   // 공휴일 or 사용자 지정 휴일
}

class WorkRecord extends Equatable {
  const WorkRecord({
    required this.id,
    required this.date,
    required this.type,
    this.startTime,
    this.endTime,
    this.memo,
  });

  final String id;
  final DateTime date;
  final WorkType type;
  final TimeOfDay? startTime; // WorkType.work 에서만 사용
  final TimeOfDay? endTime;   // WorkType.work 에서만 사용
  final String? memo;         // 선택 입력 메모

  Duration get workedDuration {
    return switch (type) {
      WorkType.work => _calcWorkDuration(),
      WorkType.vacation => Duration.zero,
      WorkType.holiday => Duration.zero,
    };
  }

  Duration _calcWorkDuration() {
    if (startTime == null || endTime == null) return Duration.zero;
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    final diff = endMinutes - startMinutes;
    return diff > 0 ? Duration(minutes: diff) : Duration.zero;
  }

  WorkRecord copyWith({
    String? id,
    DateTime? date,
    WorkType? type,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? memo,
  }) {
    return WorkRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      memo: memo ?? this.memo,
    );
  }

  @override
  List<Object?> get props => [id, date, type, startTime, endTime, memo];
}
