`PartAlreadyWritten` 오류는 MATLAB 세션에 쌓인 내부 캐시 문제로 보입니다. 오늘 같은 세션에서 시도를 많이 하셔서 그런 것 같아요.

## 해보실 것

1. **MATLAB을 완전히 종료했다가 다시 켜주세요.** (그냥 clear 말고 진짜 재시작)
2. 처음부터 순서대로 다시:

```matlab
st_setup
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```

```matlab
cfg = st_config();
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)
end
```

```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

재시작 후에도 같은 오류가 또 나면, 캡처해서 보여주세요 — 그땐 특정 CUT/Harness에 진짜 문제가 있는 건지 더 파봐야 합니다.
