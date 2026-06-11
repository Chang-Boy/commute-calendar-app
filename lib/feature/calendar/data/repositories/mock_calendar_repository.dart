import 'package:commute_calendar/feature/calendar/domain/entities/work_record_entity.dart';
import 'package:commute_calendar/feature/calendar/domain/repositories/i_calendar_repository.dart';
import 'package:flutter/material.dart';

class MockCalendarRepository implements ICalendarRepository {
  MockCalendarRepository() {
    _initDummyData();
  }

  final List<WorkRecord> _records = [];

  void _initDummyData() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;

    _records.addAll([
      // 정상 근무
      WorkRecord(
        id: '1',
        date: DateTime(y, m, 2),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      ),
      WorkRecord(
        id: '2',
        date: DateTime(y, m, 3),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 17, minute: 30),
      ),
      WorkRecord(
        id: '3',
        date: DateTime(y, m, 4),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 30),
      ),
      WorkRecord(
        id: '4',
        date: DateTime(y, m, 9),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      ),
      WorkRecord(
        id: '5',
        date: DateTime(y, m, 10),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 0),
        memo: '오전 팀 미팅',
      ),
      WorkRecord(
        id: '6',
        date: DateTime(y, m, 11),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ),
      WorkRecord(
        id: '7',
        date: DateTime(y, m, 12),
        type: WorkType.work,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ),
      // 연차
      WorkRecord(
        id: '8',
        date: DateTime(y, m, 5),
        type: WorkType.vacation,
        memo: '가족 행사',
      ),
      WorkRecord(
        id: '9',
        date: DateTime(y, m, 16),
        type: WorkType.vacation,
      ),
      // 사용자 지정 휴일
      WorkRecord(
        id: '10',
        date: DateTime(y, m, 17),
        type: WorkType.holiday,
        memo: '회사 창립기념일',
      ),
    ]);
  }

  @override
  Future<List<WorkRecord>> getRecordsByMonth(int year, int month) async {
    return _records
        .where((r) => r.date.year == year && r.date.month == month)
        .toList();
  }

  @override
  Future<void> addRecord(WorkRecord record) async {
    _records.add(record);
  }

  @override
  Future<void> updateRecord(WorkRecord record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) _records[index] = record;
  }

  @override
  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
  }
}
