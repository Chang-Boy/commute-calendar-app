# 근태 관리 달력 프로그램
- 하루 9시간 기준 한 달 동안 출퇴근 기록을 관리하며, 휴가나 휴일 등을 제외한 잔여 출근 시간을 계산해주는 서비스

## 핵심 규칙
- 적당한 규모와 의미 있는 단위 내에서 커밋을 진행한다
- 키값과 같은 보안에 민감한 정보는 환경변수로 분리한다
- 작업이 끝나면 `flutter analyze`, `dart fix --apply`와 같은 정적 검사를 실행한다
- 사용자의 지시 없이는 절대 commit, merge 등을 진행하지 않는다 (사용자가 지시하면 다시 한 번 확인)
- 주석은 명시적인 요청이 없으면 삭제하지 않는다
- 작업이 여러 단계로 나뉘어 있을 때, 사용자가 지시한 단계만 진행한다. 다음 단계는 사용자가 명시적으로 지시할 때까지 진행하지 않는다
- 구현 방식이나 의사결정이 불명확하면 사용자와 먼저 논의한다

## 코딩 컨벤션
- 짧은 코드보다 읽기 쉽고 유지보수하기 좋은 코드를 우선한다
- 한 파일의 크기는 400줄을 넘지 않도록 한다
- 함수 순서는 상위(호출자) → 하위(피호출자) 순으로 작성한다 (신문 기사 원칙: 큰 그림 먼저, 세부 구현은 아래)
- Dart 네이밍 컨벤션을 따른다
  - 클래스, enum: `PascalCase` (예: `UserProfile`, `AuthState`)
  - 변수, 함수, 메서드: `camelCase` (예: `userName`, `getUserData()`)
  - 상수: `lowerCamelCase` (예: `maxRetryCount`)
  - 파일명: `snake_case` (예: `user_model.dart`)
- 아이콘은 반드시 `PhosphorIcon` 패키지만 사용한다 (cupertino_icons, Material Icons 사용 금지)

## 에러 처리
- null 안전성을 위해 `?`, `??`, `!` 연산자를 신중하게 사용한다
- 예외 상황에 대해서는 명시적으로 처리하거나, 처리 방식이 불명확하면 사용자와 논의한다
- 예외 메시지는 사용자 입장에서 이해하기 쉽도록 작성한다

## 상태 관리 & 아키텍처
- 사용할 상태 관리는 flutter_bloc을 사용한다
- 싱글톤 방식을 선호한다
- 아키텍처는 BLoC 기반 Clean Architecture를 사용한다
- 의존성 주입(DI)은 GetIt을 사용하여 `lib/core/di/service_locator.dart`에서 관리한다
  - 서비스 로케이터: `final getIt = GetIt.instance`
  - 초기화: `main()` 함수에서 `await setupServiceLocator()` 호출
  - 사용: `getIt<ServiceType>()`로 등록된 서비스 접근

## 디자인 컨벤션
- iOS, Android뿐 아니라 Mac, Windows까지 고려한 반응형 디자인을 구현한다
- 화려한 디자인보다 심플하고 명확한 디자인을 선호한다
- Material스러운 디자인들(색상, 기본 제공 위젯)은 지양하고 커스텀하여 구현한다

## 명령어

### 의존성 관리
```bash
flutter pub get        # 패키지 설치
flutter pub upgrade    # 패키지 업그레이드
```

### 코드 생성
```bash
flutter pub run build_runner build --delete-conflicting-outputs   # 코드 생성
```

### 정적 분석
```bash
flutter analyze    # 정적 분석 (flutter lint은 유효한 명령어가 아님)
dart fix --apply   # 분석 오류 자동 수정
```

### 실행 / 빌드
```bash
flutter run        # 디버그 실행
flutter build apk  # Android APK 빌드
flutter build ipa  # iOS IPA 빌드
```