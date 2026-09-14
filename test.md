원본 코드가 업데이트되면서 명령어 방식이 바뀌었습니다. 이제부터는 아래 새 방식으로 실행해주세요.

## 무엇이 바뀌었나

- `RunMode='STEP1'`, `RunMode='STEP2_TO_6'` 같은 옵션은 **완전히 제거**됨
- `PreparationMode`, `FromStage`, `ReportMode` 옵션도 이 함수에서는 제거됨
- 대신 **준비 단계**(Harness/SLDV/Assessment 등, 매니페스트 갱신 포함)는 원래 쓰던 `st_run_from_harness`로 하고, **실행 단계**는 `Action` 파라미터로 합니다

## 새 실행 순서

1단계 - 준비만 하기 (테스트 실행은 안 함, SLDV 매니페스트도 여기서 갱신됨):

```matlab
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```

2단계 - Standalone Coverage 실행 (예전 STEP2_TO_6에 해당):

```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

기존에 겪으신 "SLDV 매니페스트 안 맞음" 문제는 1단계에서 `PreparationMode=FORCE`로 매번 새로 반영되니, 엑셀 값(`DataFileFormat=MAT` 포함) 다시 확인하신 뒤 이 순서로 실행해주세요.
