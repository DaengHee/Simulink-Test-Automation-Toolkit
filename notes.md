# 지금 할 일

`test` 브랜치를 원본 v2 소스로 리셋했습니다. 이제부터 기본 실행은 이겁니다:

```matlab
% EXECUTE -> PACKAGE -> SUMMARY
info = st_run_standalone_coverage_pipeline();

% 생성된 결과를 읽기 전용으로 한 화면에서 확인
[code, summary, details] = st_check_standalone_coverage();
```

전체 계약을 통과한 코드만 `1111111111`입니다. 화면 출력은 최대 20줄이며, 전체 CUT
결과는 `details` table에서 확인합니다.

## 그 전에: External Harness 문제부터 확인

점검해보니 모델의 **Harness 8개 전부**가 `External=true, FilePathOK=false`로 똑같이
나왔습니다. 하나씩 개별 문제가 아니라, 이 8개가 전부 복제(clone)된 **템플릿 Harness
자체가 깨진 상태**라서 복제할 때마다 같은 문제가 그대로 옮겨진 겁니다.

먼저 어떤 Harness가 템플릿인지 확인하세요 (읽기 전용, 타겟 시트 조회만 함):

```matlab
cfg = st_require_runtime_target();
T = st_load_targets(cfg.OnlyEnabled);
T(:, {'No','HarnessName','TestPreparationSource','SourceCUTPath','SourceHarnessName'})
```

`TestPreparationSource`가 `HARNESS_CLONE`인 행들의 `SourceHarnessName`을 보면 전부 같은
이름 하나를 가리킬 겁니다 — 그게 템플릿입니다.

**고칠 방법 (택1):**
1. **템플릿만 고치고 다시 복제(권장)** — 템플릿 Harness를 Simulink에서 열어 Harness
   속성의 "Save harness as separate file" 체크를 끄고 모델 저장 → 그 다음 `cfg.OverwriteHarness = true`로 설정하고 HARNESS 단계(`st_create_harnesses` 등)를 다시 돌려서 8개를 전부 재복제. 앞으로 또 복제해도 문제가 안 생김.
2. **지금 있는 8개를 각각 직접 고치기** — 8개 Harness를 하나씩 열어서 같은 체크를
   끄고 저장. 당장은 빠르지만 나중에 템플릿에서 또 복제하면 다시 깨짐.

정리가 끝나면 위 "기본 실행" 블록을 돌리세요. 출력 전체를 캡처해서 보여주세요.

## 만약 실행 후 결과를 Test Manager로 열고 싶다면

```matlab
cfg = st_config();
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);
run(m.TestManagerLauncher)
```

`info` 변수가 없으면(MATLAB 재시작 등) `info.PipelineId` 대신 `'LATEST'`를 넣으세요.
