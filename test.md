현재 v2 최신 기준 전체 실행 순서입니다.

## 0단계 - 문제 있는 CUT 제외

`TestManagement.xlsx` → `Targets` 시트에서, Size=-1 문제 났던 그 CUT 행의 `Enabled`를 `FALSE`로 바꿔주세요.

## 1단계 - 준비 (Harness/SLDV/Assessment 등, 테스트는 실행 안 함)

```matlab
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```

## 2단계 - Standalone Coverage 실행

```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

## 3단계 - 결과 검증

```matlab
[code, summary] = st_check_standalone_coverage('PipelineId', info.PipelineId)
disp(code)
```

`code`가 `1111111111`이면 34개 전부 정상입니다.
