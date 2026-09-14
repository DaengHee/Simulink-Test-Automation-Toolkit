정리: 지금 v2에서 실행하는 전체 순서입니다.

## 1단계 - 준비 (Harness/SLDV/Assessment 등, 테스트는 실행 안 함)

```matlab
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```

## 2단계 - Standalone Coverage 실행 (예전 STEP2_TO_6에 해당)

```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

## 3단계 - 결과 검증 (오늘 새로 추가된 진단 명령, 선택)

```matlab
[code, summary] = st_check_standalone_coverage('PipelineId', info.PipelineId)
disp(code)
```

`code`가 `1111111111`이면 전부 정상입니다.

---

참고: `Size=-1` Assessment 문제 고치는 코드는 아직 작업 중이라 이 순서로 돌리면 아까 그 CUT에서 다시 걸릴 수 있습니다. 그건 이어서 고친 뒤 별도로 알려드릴게요.
