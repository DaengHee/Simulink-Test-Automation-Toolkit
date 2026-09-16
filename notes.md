# 지금 할 일

이전에 드린 "기본 실행" 명령에 **필수 준비 단계가 빠져 있었습니다.** External Harness
경로 오류는 하네스가 깨진 게 아니라, 이 준비 단계 없이 바로 실행해서 생긴 것으로
보입니다. 아래 순서로 다시 시도해주세요.

## 1단계: Harness/입력/Assessment/Test Case 준비 (먼저 실행)

```matlab
st_run_from_harness('PreparationMode', 'FORCE', 'ExecuteTests', false);
```

이 명령이 Harness 생성·Signal Editor 입력·Assessment·Test Case를 전부 준비합니다.
`st_run_standalone_coverage_pipeline`은 이 준비가 끝났다고 가정하고 실행만 하므로,
이 단계 없이 바로 2단계로 가면 지금까지 본 것 같은 오류가 날 수 있습니다.

## 2단계: 실행 -> 패키징 -> 요약

```matlab
info = st_run_standalone_coverage_pipeline();
[code, summary, details] = st_check_standalone_coverage();
```

전체 계약을 통과한 코드만 `1111111111`입니다. 화면 출력은 최대 20줄이며, 전체 CUT
결과는 `details` table에서 확인합니다.

1단계 이후에도 External Harness 오류가 또 나면 그때 다시 캡처해서 보여주세요 — 그때는
진짜 하네스 쪽 문제로 봐야 합니다. 지금은 순서 문제일 가능성이 높으니 먼저 이걸로
시도해주세요.

## 결과를 Test Manager로 열고 싶으면

```matlab
cfg = st_config();
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);
run(m.TestManagerLauncher)
```

`info` 변수가 없으면(MATLAB 재시작 등) `info.PipelineId` 대신 `'LATEST'`를 넣으세요.
