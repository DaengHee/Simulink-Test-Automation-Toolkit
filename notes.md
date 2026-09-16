# 지금 할 일

지금까지 드린 `PreparationMode FORCE` 명령은 잘못됐습니다 — Harness/Signal
Editor/Assessment를 이미 직접 다 설정해두셨다고 하셨는데, FORCE는 그 설정을
새로 덮어씁니다. `docs/manual/standalone-run.md`에 있는, 이미 준비 끝난 상태
전용 절차로 바꿉니다. FORCE는 전혀 안 씁니다.

## 0단계: (아직 안 했으면) 원본 모델 저장하고 닫기

standalone 실행은 원본 Top Model과 같은 이름으로 격리된 복사본을 만들어서 돌립니다.
그래서 원본 Top Model이 열려 있으면 안 됩니다. 지금 열려 있는 Harness/Top Model을
저장하고 닫아주세요 (자동으로 안 닫힙니다).

## 1단계: 준비 상태 확인 (읽기 전용)

```matlab
st_setup
[ready, checks] = st_check_readiness('Workflow','STANDALONE','FromStage','EXECUTE');
disp(checks)
assert(ready.Ready, 'Resolve readiness checks first.');
```

`ready.Ready`가 false면 `checks`에 뭐가 문제인지 나옵니다 — 그거 먼저 캡처해서
보여주세요. (모델을 여러 개 등록해서 profile로 쓰고 계신 게 아니면 이 단계는
`st_select_model_profile` 없이 지금 쓰던 모델 그대로 씁니다.)

## 2단계: EXECUTE부터 재개 (SLDV/Harness/Signal Editor/Assessment는 전혀 안 건드림)

```matlab
info = st_run_from_stage('Workflow','STANDALONE','FromStage','EXECUTE');
[code, summary, details] = st_check_standalone_coverage('PipelineId', info.PipelineId);
disp(code)
disp(summary)
disp(details)
```

전체 계약을 통과한 코드만 `1111111111`입니다. 결과 캡처해서 보여주세요.

## 결과를 Test Manager로 열고 싶으면

```matlab
cfg = st_config();
m = st_load_standalone_pipeline_manifest(cfg.StandaloneCoverageRootDir, info.PipelineId);
for k = 1:numel(m.Targets)
    addpath(m.Targets(k).OutputDirectory);
end
sltest.testmanager.TestFile(m.TestManagerFile);
sltest.testmanager.view;
```

또는 launcher로 한 번에:

```matlab
run(m.TestManagerLauncher)
```
