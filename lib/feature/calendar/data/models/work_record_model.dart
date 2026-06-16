import 'package:flutter/material.dart';

import '../../domain/entities/work_record_entity.dart';

class WorkRecordModel extends WorkRecord {
  const WorkRecordModel({
    required super.id,
    required super.date,
    required super.type,
    super.startTime,
    super.endTime,
    super.memo,
  });

  factory WorkRecordModel.fromJson(Map<String, dynamic> json) {
    return WorkRecordModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: WorkType.values.byName(json['type'] as String),
      startTime: _parseTime(json['start_time'] as String?),
      endTime: _parseTime(json['end_time'] as String?),
      memo: json['memo'] as String?,
    );
  }

  factory WorkRecordModel.fromEntity(WorkRecord entity) {
    return WorkRecordModel(
      id: entity.id,
      date: entity.date,
      type: entity.type,
      startTime: entity.startTime,
      endTime: entity.endTime,
      memo: entity.memo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
      'type': type.name,
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
      'memo': memo,
    };
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
