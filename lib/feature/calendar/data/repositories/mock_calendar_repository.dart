import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:commute_calendar/feature/calendar/domain/repositories/i_calendar_repository.dart';
import 'package:flutter/material.dart';

class MockCalendarRepository implements ICalendarRepository {
  MockCalendarRepository() {
    _initDummyData();
  }

  final List<WorkRecordEntity> _records = [];

  void _initDummyData() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;

    _records.addAll([
      // 정상 근무
      WorkRecordEntity(
        id: '1',
        date: DateTime(y, m, 2),
        type: WorkType.work,
        workMinutes: 540, // 9h
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      ),
      WorkRecordEntity(
        id: '2',
        date: DateTime(y, m, 3),
        type: WorkType.work,
        workMinutes: 540, // 9h
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 17, minute: 30),
      ),
      WorkRecordEntity(
        id: '3',
        date: DateTime(y, m, 4),
        type: WorkType.work,
        workMinutes: 570, // 9h 30m
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 30),
      ),
      WorkRecordEntity(
        id: '4',
        date: DateTime(y, m, 9),
        type: WorkType.work,
        workMinutes: 540, // 9h
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      ),
      WorkRecordEntity(
        id: '5',
        date: DateTime(y, m, 10),
        type: WorkType.work,
        workMinutes: 540, // 9h
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 0),
        memo: '오전 팀 미팅',
      ),
      WorkRecordEntity(
        id: '6',
        date: DateTime(y, m, 11),
        type: WorkType.work,
        workMinutes: 480, // 8h
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ),
      WorkRecordEntity(
        id: '7',
        date: DateTime(y, m, 12),
        type: WorkType.work,
        workMinutes: 540, // 9h
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ),
      // 출퇴근 시간 없이 workMinutes만 있는 케이스 (nullable 검증용)
      WorkRecordEntity(
        id: '11',
        date: DateTime(y, m, 13),
        type: WorkType.work,
        workMinutes: 510, // 8h 30m
        memo: '재택근무',
      ),
      // 연차
      WorkRecordEntity(
        id: '8',
        date: DateTime(y, m, 5),
        type: WorkType.vacation,
        memo: '가족 행사',
      ),
      WorkRecordEntity(
        id: '9',
        date: DateTime(y, m, 16),
        type: WorkType.vacation,
      ),
      // 사용자 지정 휴일
      WorkRecordEntity(
        id: '10',
        date: DateTime(y, m, 17),
        type: WorkType.holiday,
        memo: '회사 창립기념일',
      ),
    ]);
  }

  @override
  Future<List<WorkRecordEntity>> getRecordsByMonth(int year, int month) async {
    return _records
        .where((r) => r.date.year == year && r.date.month == month)
        .toList();
  }

  @override
  Future<void> addRecord(WorkRecordEntity record) async {
    _records.add(record);
  }

  @override
  Future<void> updateRecord(WorkRecordEntity record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) _records[index] = record;
  }

  @override
  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
  }
}
