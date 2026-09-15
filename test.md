추출된 결과를 Test Manager에서 여는 방법입니다.

## 왜 그냥 .mldatx를 더블클릭하면 안 되는지

결과 폴더의 `TestManager\OBC_....mldatx`는, 각 Test Case의 Model이 **CUT별로 따로 뽑아둔 독립 모델(.slx)**을 가리키고 있어요. 그런데 그 .slx들은 CUT마다 **다른 폴더**(`004_...`, `005_...` 등)에 흩어져 있어서, MATLAB이 그 경로를 모르면 못 찾습니다. 그래서 .mldatx만 열면 `..._Harness1을 찾을 수 없음` 오류가 나요.

**launcher 스크립트**가 이걸 대신 해줍니다:
1. CUT별 결과 폴더를 전부 MATLAB path에 추가
2. 각 독립 모델을 미리 load
3. 각 Test Case에 패키징된 CVF(커버리지 필터)를 적용
4. 그 상태로 Test Manager를 염

## 해보실 것

### 1단계 — 새로 실행 (필수)

launcher는 **어제 돌린 결과에는 없습니다** (그때 코드엔 이 기능이 없었어요). 새로 한 번 돌려야 해요.

`git pull` + MATLAB 재시작 후, 원본 Top Model과 Test File을 저장하고 닫은 다음:

```matlab
st_setup;
cfg = st_require_runtime_target('LoadModel', false);
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)
end
info = st_run_standalone_coverage_pipeline( ...
    'Action', 'ALL', ...
    'ContinueOnFailure', true, ...
    'FailOnNonPass', false);
```

### 2단계 — Test Manager 열기

```matlab
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);
assert(isfile(m.TestManagerLauncher), ...
    'launcher가 없는 예전 패키지입니다. 1단계를 먼저 돌리세요.');
run(m.TestManagerLauncher)
```

Test Manager가 열리고, 출력에 `Models=N | CVFs=N`이 나옵니다. **N이 CUT 개수(34)와 같아야** 정상이에요.

### 3단계 — 결과 확인

Test Manager에서 각 Test Case를 눌러보면:
- **Model** 필드가 그 CUT의 독립 모델(`..._Harness25` 등)로 되어있고
- 결과의 Coverage에 패키징된 CVF가 적용된 상태로 보입니다

문제가 있으면 launcher 출력 전체를 캡처해서 보여주세요.
