# 근태 입력 방식 변경 — 구현 계획서

## 프로젝트 현황

현재 근무 기록은 **출퇴근 시간(start/end)을 필수 입력**받고, 총 근무시간(`workedDuration`)을
이로부터 **파생 계산**한다.
하지만 사용자에게는 출퇴근 시각보다 **"오늘 몇 시간 몇 분 일했는가"** 가 더 중요하다.

따라서 입력 방식을 뒤집는다.

- **총 근무시간을 직접 입력**(필수) → 이 값이 잔여시간 계산의 **source of truth**
- **출퇴근 시간은 선택 입력**(nullable) → 표시용 부가정보일 뿐 계산에 영향 없음

---

## 결정 사항

| 항목 | 결정 |
|------|------|
| **계산 기준값** | **근무시간이 source of truth.** 출퇴근 시간은 nullable 부가정보(표시용)이며 근무시간을 자동 변경하지 않는다. |
| **DB 스키마** | `work_records` 테이블에 `work_minutes`(int, nullable) 컬럼 추가. `start_time`/`end_time`은 nullable 유지. |
| **출퇴근 입력 UI** | 다이얼로그 대신 **인라인 펼침(Expansion)**. "출퇴근 시간 입력" 버튼 탭 시 같은 바텀시트 내에서 CupertinoPicker가 아래로 펼쳐짐. |
| **추상체** | Repository만 인터페이스(`ICalendarRepository`) 유지. DataSource는 직접 구현. |
| **디자인** | 기존 `ThemeService` 테마/디자인 시스템 준수. `PhosphorIcon`만 사용. |

> **규칙**: Phase 순서 엄수. 각 Phase 완료 후 `flutter analyze` 통과 확인. 사용자 지시 없이 커밋하지 않음.

---

## 핵심 설계: `workedDuration`을 저장값으로 전환

현재 `WorkRecordEntity.workedDuration`은 start/end에서 계산하는 getter다.
이 getter를 **저장된 `workMinutes` 기반**으로 바꾸면, 이를 소비하는 코드
(`calculate_monthly_stats_usecase.dart`, `calendar_widget.dart`, `day_info_widget.dart`)는
**수정 없이 그대로 동작**한다. → 변경 파급을 최소화하는 핵심 전략.

```dart
// 변경 전: start/end에서 파생
Duration get workedDuration => _calcWorkDuration();

// 변경 후: 저장된 분(分)을 반환
Duration get workedDuration => switch (type) {
  WorkType.work => Duration(minutes: workMinutes ?? 0),
  _ => Duration.zero,
};
```

---

## Phase 1: 모델링 + DB 스키마

**목표**: `WorkRecordEntity` / `WorkRecordModel`에 `workMinutes` 도입, `workedDuration`을 저장값 기반으로 전환

> **의존성**: 없음 (시작점)

### 핵심 작업

**`work_record_entity.dart`**
- `final int? workMinutes;` 필드 추가 (총 근무시간을 분 단위로 저장, work 타입에서만 사용)
- `workedDuration` getter: `_calcWorkDuration()` → `Duration(minutes: workMinutes ?? 0)` 기반으로 변경
- `_calcWorkDuration()` 제거 (더 이상 파생 계산하지 않음)
- `startTime`/`endTime`은 nullable 유지 (부가정보)
- `copyWith`, `props`에 `workMinutes` 반영

**`work_record_model.dart`**
- `fromJson`: `work_minutes`(int?) 파싱 추가
- `toJson`: `work_minutes` 직렬화 추가
- `fromEntity`: `workMinutes` 전달

**DB 스키마 (Supabase 콘솔에서 직접 적용 — 사용자 진행)**
```sql
ALTER TABLE work_records ADD COLUMN work_minutes integer;
-- start_time, end_time: nullable 유지 (이미 nullable)
```

### 파일 구조
```
lib/feature/calendar/
  domain/entities/work_record_entity.dart   (수정: workMinutes, workedDuration)
  data/models/work_record_model.dart         (수정: work_minutes 직렬화)
```

### 완료 체크리스트
- [x] `WorkRecordEntity`에 `workMinutes` 필드 추가
- [x] `workedDuration` getter를 `workMinutes` 기반으로 변경, `_calcWorkDuration()` 제거
- [x] `copyWith` / `props`에 `workMinutes` 반영
- [x] `WorkRecordModel` fromJson/toJson/fromEntity에 `work_minutes` 반영
- [ ] Supabase `work_records`에 `work_minutes` 컬럼 추가 (사용자)
- [x] `flutter analyze` 통과

---

## Phase 2: Data / Domain 레이어 검증 및 반영

**목표**: 데이터·도메인 레이어가 `workMinutes`를 정상 처리하는지 검증하고 영향 파일 정리

> **의존성**: Phase 1 완료 후 진행

### 핵심 작업

**`work_record_data_source.dart`** (확인)
- `addRecord`/`updateRecord`는 `model.toJson()`을 그대로 사용 → Phase 1 반영으로 `work_minutes` 자동 포함. 추가 수정 불필요 여부 확인.

**`calculate_monthly_stats_usecase.dart`** (확인)
- `record.workedDuration` 사용부(L66)는 getter 변경으로 **자동 동작**. 로직 수정 불필요 확인.

**`mock_calendar_repository.dart`** (수정)
- 목 데이터를 `workMinutes` 기반으로 업데이트 (기존 start/end만 있는 데이터 보정).
- 일부는 출퇴근 시간 없이 `workMinutes`만 있는 케이스 포함하여 nullable 검증용 데이터 추가.

### 파일 구조
```
lib/feature/calendar/
  data/datasources/work_record_data_source.dart        (확인)
  domain/usecases/calculate_monthly_stats_usecase.dart (확인)
  data/repositories/mock_calendar_repository.dart       (수정: workMinutes 목 데이터)
```

### 완료 체크리스트
- [x] DataSource가 `work_minutes`를 정상 저장/조회하는지 확인
- [x] 통계 usecase가 `workedDuration` 변경으로 정상 동작하는지 확인
- [x] `mock_calendar_repository`를 `workMinutes` 기반으로 업데이트 (출퇴근 null 케이스 포함)
- [x] `flutter analyze` 통과

---

## Phase 3: 입력 UI — 근무시간 직접 입력 + 인라인 출퇴근 펼침

**목표**: `WorkRecordBottomSheet`를 근무시간 TextField(필수) + 출퇴근 인라인 펼침(선택) 구조로 개편

> **의존성**: Phase 1~2 완료 후 진행

### 입력 플로우
```
FAB → 근무 선택
  → 바텀시트 표시
    1. [필수] 근무시간 입력: "시간"/"분" TextField (숫자만)
    2. [선택] "출퇴근 시간 입력" 버튼 탭 → 아래로 CupertinoPicker 펼침(Expansion)
       - 펼친 상태에서 출근/퇴근 시각 선택 (nullable)
       - 다시 접으면 입력값 유지 또는 초기화 (접어도 값 유지 권장)
    3. 메모 입력 (선택, 기존과 동일)
    4. 저장
```

### 핵심 작업

**`work_record_bottom_sheet.dart`** (수정)
- 상태 추가: `_workHours`, `_workMinutes`(필수 입력), `_isTimeExpanded`(펼침 여부)
- 근무시간 입력 위젯 신규: "시간" / "분" TextField 2개 (`TextInputType.number`, 입력 포맷터로 숫자만)
  - work 타입에서만 표시. vacation/holiday는 기존대로 메모만.
- 기존 출퇴근 CupertinoPicker(`_buildTimePickers`)를 **인라인 펼침 영역**으로 재배치
  - "출퇴근 시간 입력" 토글 버튼(`PhosphorIcon` + 라벨) → `AnimatedSize`/`AnimatedCrossFade`로 펼침/접힘
  - 출퇴근 입력은 nullable: 펼치지 않거나 미입력 시 `startTime`/`endTime`은 null
- `_buildDurationPreview`: 출퇴근 기반 미리보기 → **근무시간 TextField 입력값 미리보기**로 변경
- `_save()`:
  - `workMinutes = _workHours * 60 + _workMinutes`
  - `startTime`/`endTime`: 펼쳐서 입력했을 때만 값, 아니면 null
  - `existingRecord` 편집 시 `workMinutes`/펼침 상태 초기화 반영

### 엣지/에러 케이스
- 근무시간 미입력(0시간 0분) 저장 시도 → 저장 버튼 비활성 또는 Toast 안내 ("근무시간을 입력해주세요")
- 분(分) 60 이상, 음수, 비숫자 입력 → 입력 포맷터/검증으로 차단
- 시간 상한 가드 (예: 24시간 초과 입력 방지 — 협의 필요 시 표시)
- 출퇴근만 입력하고 근무시간 미입력 → 근무시간 필수이므로 저장 불가 안내

### 파일 구조
```
lib/feature/calendar/presentation/widgets/
  work_record_bottom_sheet.dart   (수정: 근무시간 TextField + 인라인 출퇴근 펼침)
```
> 파일이 400줄 초과 시 입력 위젯(근무시간/출퇴근 펼침)을 별도 위젯 파일로 분리.

### 완료 체크리스트
- [x] 근무시간 "시간"/"분" TextField 추가 (숫자만, 필수)
- [x] "출퇴근 시간 입력" 토글 버튼 + 인라인 펼침(Expansion) 구현
- [x] 출퇴근 picker를 펼침 영역으로 이동, nullable 처리
- [x] 미리보기를 근무시간 입력값 기반으로 변경 (별도 미리보기 제거, 입력 필드 자체가 시각적 피드백)
- [x] `_save()`에서 `workMinutes` + nullable start/end 저장
- [x] 편집(`existingRecord`) 시 초기값 복원
- [x] 엣지/에러 케이스 처리 (미입력·범위 검증)
- [x] `flutter analyze` 통과

---

## Phase 4: 표시 UI 수정 — 근무시간 우선 노출

**목표**: 기록 표시 위젯을 "근무시간 우선, 출퇴근은 부가" 구조로 정리

> **의존성**: Phase 1~3 완료 후 진행

### 핵심 작업

**`day_info_widget.dart`** (`_RecordTile._buildWorkContent` 수정)
- **근무시간(`workedDuration`)을 주(主) 정보로 강조 표시**
- 출퇴근 시간(start/end)은 **있을 때만** 보조 텍스트로 표시, 없으면 생략
- 기존 "시간 정보 없음" 분기 → 출퇴근이 없어도 근무시간은 항상 표시되므로 문구 재정리

**`calendar_widget.dart`** (`_buildCellLabel` 확인)
- 셀에 `record.workedDuration` 표시 → getter 변경으로 자동 동작. 표시 형식 확인.

### 파일 구조
```
lib/feature/calendar/presentation/widgets/
  day_info_widget.dart    (수정: 근무시간 우선, 출퇴근 조건부 표시)
  calendar_widget.dart    (확인)
```

### 완료 체크리스트
- [x] `_RecordTile`에서 근무시간 강조 표시
- [x] 출퇴근 시간은 존재할 때만 보조 표시
- [x] 출퇴근 없는 기록의 표시 문구 정리
- [x] `calendar_widget` 셀 표시 정상 동작 확인
- [x] `flutter analyze`, `dart fix --apply` 최종 통과

---

## 파일 전체 구조 (완료 후)

```
lib/feature/calendar/
  domain/
    entities/work_record_entity.dart                  (수정: workMinutes, workedDuration)
  data/
    models/work_record_model.dart                     (수정: work_minutes 직렬화)
    datasources/work_record_data_source.dart          (확인)
    repositories/mock_calendar_repository.dart         (수정: 목 데이터)
  domain/usecases/
    calculate_monthly_stats_usecase.dart              (확인)
  presentation/widgets/
    work_record_bottom_sheet.dart                      (수정: 입력 방식 개편)
    day_info_widget.dart                               (수정: 표시 방식)
    calendar_widget.dart                               (확인)
```

DB: `work_records.work_minutes` (integer, nullable) 컬럼 추가 — 사용자가 Supabase 콘솔에서 적용.

---

## 참고사항
- **추상체는 Repo만**: `ICalendarRepository` 유지. DataSource·Model은 직접 구현.
- **source of truth는 `workMinutes`**: 출퇴근 시간이 있어도 근무시간을 자동 변경하지 않음.
- **변경 최소화 전략**: `workedDuration` getter만 저장값 기반으로 바꿔 소비측 코드 파급 최소화.
- **디자인**: 기존 `ThemeService` 테마/색상/타이포 준수. Material 기본 위젯 지양, `PhosphorIcon`만 사용.
- **단순함 우선**: 가독성 좋고 복잡하지 않게 구현.
- **파일 크기**: 400줄 초과 시 위젯 분리.
- **커밋**: 사용자 명시적 지시 없이 커밋하지 않음.
</content>
</invoke>
