지난번 수정(Dirty일 때만 저장)으로는 `PartAlreadyWritten`이 안 막혔습니다. 진짜 원인을 다시 찾아서 고쳤어요 — 하네스 내보내기가 원본 복사 모델을 dirty로 만드는데, 그걸 "다시 저장"하는 대신 "그냥 닫고 디스크에 있던 걸 다시 불러오기"로 바꿨습니다.

## 해보실 것

1. `git pull` 로 방금 올라간 수정 받기
2. MATLAB 완전 재시작
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

또 같은 오류(`PartAlreadyWritten`) 나면 캡처해서 보여주세요 — 이번엔 어느 CUT/하네스에서 나는지도 같이 알려주시면 더 빨리 찾을 수 있어요.
