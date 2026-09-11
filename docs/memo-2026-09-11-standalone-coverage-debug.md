# 디버깅 메모 (2026-09-11)

다른 PC에서 이어서 진행할 수 있도록 지금까지 상황을 정리합니다.

## 지금 하려던 것

`st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')`로 Standalone
Coverage 파이프라인 실행 중 오류 2개 발생.

## 1. 경로 길이 초과 오류 — 이미 수정됨 (dev 브랜치에만 있음)

```
MATLAB:cd:DirectoryNameTooLong
현재 폴더를 '...\result\standalone_coverage\...\.work\exports\tpXXXXXXXX...
\template\workspace\standalone\{CUTName}'(으)로 변경할 수 없습니다.
```

- 원인: `st_export_test_bundle.m`이 `tempname()`으로 만드는 staging 폴더 이름이
  38자짜리 GUID라서, 그 아래 `template/workspace/standalone/{CUTName}`까지
  중첩되면 프로젝트 경로가 깊을 때 Windows 260자 제한을 넘음.
- 수정: `tempname(destination)` 대신 짧은 `short_staging_directory()` 헬퍼로
  교체 (`~exp` + 8자 랜덤 토큰, 총 12자로 26자 단축).
- **커밋 위치: `dev` 브랜치의 `f94608e`.** `test` 브랜치(원본 v2 그대로 유지하는
  브랜치)에는 반영 안 되어 있음. 이 수정을 쓰려면 `dev`에서 실행해야 함.

## 2. Missing dependencies: {CUT_NAME} — 원인 조사 중, 미해결

```
simtest:ExportDependencyMissing: Cannot create a complete bundle.
Missing dependencies: {CUT_NAME}
```

`st_export_test_bundle.m`이 내부적으로 호출하는 MATLAB 기본 함수
`dependencies.fileDependencyAnalysis(cfg.ModelFile, 'AnalyzeToolboxFiles', false)`가
`{CUT_NAME}`을 missing으로 보고함.

### 지금까지 확인한 것

- `which('{CUT_NAME}', '-all')` → 아무것도 안 나옴 (path 위 파일 아님)
- 모델을 직접 열어보면 `{CUT_NAME}` 블록이 존재함
- 이 블록이 **Simulink Function**(보라색 블록) 안에 들어있음

### 가설
Simulink Function / Function Caller 구조를 MATLAB의 의존성 분석기가
외부 파일 참조로 오인해서 false positive를 내는 것일 수 있음. 아직 확정 아님.

### 다음에 실행해서 확인해야 할 것

```matlab
cfg = st_require_runtime_target();
handles = find_system(cfg.TopModel, 'FindAll', 'on', 'Name', '{CUT_NAME}');
get_param(handles, 'BlockType')
get_param(handles, 'Parent')
```

이 두 결과를 보면:
- `{CUT_NAME}`이 Simulink Function **정의 블록**인지
- 그걸 부르는 **Function Caller**인지
- 아니면 그 안에 있는 그냥 **일반 Subsystem(CUT)**인지

를 구분할 수 있음. 결과 나오면 이어서 원인 확정하고 필요하면 코드 수정.

## 브랜치 상태 요약

| 브랜치 | 이 문제 관련 상태 |
| --- | --- |
| `dev` | 경로 길이 수정(`f94608e`) 반영됨. 작업은 여기서 이어가는 게 맞음 |
| `test` | 원본 v2 그대로, 수정 없음 (이 메모만 추가됨) |
| `feat/harness-workflow-v2` (로컬 북마크) | 원본 v2 그대로, upstream 추적용 |
