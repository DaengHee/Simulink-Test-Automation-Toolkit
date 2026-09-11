모델 세션/cleanup 버그 2개 고쳤습니다. `test` 브랜치에 있어요.

## 1. 먼저 지금 뜬 dirty model 에러부터 정리 (필수)

이전 실패한 시도 때문에 Top Model이 메모리에 로드된 채 dirty 상태로 남아있어요.
MATLAB에서:

```matlab
cfg = st_config();
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)   % 0 = 저장하지 않고 닫기(변경사항 버림)
end
```

(변경사항을 저장하고 싶으면 `close_system(cfg.TopModel, 0)` 대신 `save_system(cfg.TopModel); close_system(cfg.TopModel);`)

## 2. 최신 받고 재실행

```bash
git pull
```

```matlab
st_setup
info = st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')
```

에러 없이 끝까지 도는지 확인해주세요.
