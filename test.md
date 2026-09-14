현재 v2 최신 기준 전체 실행 순서입니다. (1단계와 2단계 사이에 모델 닫는 단계가 추가됐습니다.)

## 0단계 - 문제 있는 CUT 제외

`TestManagement.xlsx` → `Targets` 시트에서, Size=-1 문제 났던 그 CUT 행의 `Enabled`를 `FALSE`로 바꿔주세요.

## 1단계 - 준비 (Harness/SLDV/Assessment 등, 테스트는 실행 안 함)

```matlab
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```

## 1.5단계 - 모델 닫기 (새로 필요해짐)

```matlab
cfg = st_config();
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)
end
```

## 2단계 - Standalone Coverage 실행

```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

## 3단계 - 전체 요약 확인

```matlab
[code, summary] = st_check_standalone_coverage('PipelineId', info.PipelineId)
disp(code)
```

`code`가 `1111111111`이면 전부 정상.

## 4단계 - CUT별 상세 결과 확인 (선택, 문제 있을 때 유용)

```matlab
for i = 1:numel(info.Targets)
    fprintf('\n[%03d] %s | Package=%s\n%s\n', ...
        info.Targets(i).No, info.Targets(i).CUTName, ...
        info.Targets(i).PackageStatus, info.Targets(i).Message);
end
```
