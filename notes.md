방금 돌리신 결과를 Test Manager에서 여는 방법입니다. 아래 한 블록만 실행하면 돼요.

## 해보실 것

```matlab
cfg = st_config();
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);

assert(isfile(m.TestManagerLauncher), ...
    'launcher가 없는 패키지입니다. 최신 코드로 다시 돌려야 합니다.');
run(m.TestManagerLauncher)
```

이게 자동으로:
1. CUT별 결과 폴더를 MATLAB path에 등록하고
2. 각 standalone Harness 모델을 load하고
3. 각 Test Case에 패키징된 CVF(커버리지 필터)를 적용한 뒤
4. Test Manager를 엽니다

## 확인할 것

- 출력에 `Models=N | CVFs=N`이 나오는데, **N이 CUT 개수와 같아야** 정상이에요
- Test Manager가 열리면 각 Test Case의 **Model** 필드가 `..._Harness1`, `..._Harness2` 처럼 CUT별 독립 모델 이름으로 보여야 합니다

## 만약 `info` 변수가 없다면

MATLAB을 재시작하셨거나 `info`가 날아갔으면, 아래처럼 최신 결과로 여세요:

```matlab
cfg = st_config();
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, 'LATEST');
run(m.TestManagerLauncher)
```

오류 나면 출력 전체를 캡처해서 보여주세요.
