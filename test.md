`PartAlreadyWritten` 오류 원인을 찾아서 코드로 고쳤습니다. (재시작 문제 아니었음 — 같은 모델을 반복 저장하다 생기는 버그였음)

## 해보실 것

1. `git pull` 로 방금 올라간 수정 받기
2. MATLAB 완전 재시작 (혹시 몰라 한번 더)
3. 처음부터 순서대로 다시:

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

4. 다 끝나면 전체 요약 확인:

```matlab
[code, summary] = st_check_standalone_coverage('PipelineId', info.PipelineId);
disp(code)
```

또 같은 오류(`PartAlreadyWritten`) 나면 캡처해서 보여주세요.
