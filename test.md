원본 레포 문서(`docs/manual/standalone-coverage-runtime.md` 6장)에 나온 방법 그대로입니다.

## 왜 그냥 .mldatx만 열면 안 되는지

Test Manager의 **Model 속성은 "파일 경로"가 아니라 "모델 이름"**이에요. 그래서 폴더 버튼으로 `.slx`를 직접 골라도, **그 결과 폴더가 MATLAB path에 없으면** Refresh/All 할 때 `..._Harness1`을 다시 못 찾습니다. 결국 핵심은 **"결과 폴더를 path에 넣고, 모델을 미리 load해두는 것"**이에요.

---

## 방법 A — launcher (원본에서 권장하는 방법)

모델 load + CVF 적용 + Test Manager 열기를 한 번에 해줍니다.

```matlab
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);

assert(isfile(m.TestManagerLauncher), ...
    '이 Pipeline은 Test Manager launcher가 없는 이전 패키지입니다.');
run(m.TestManagerLauncher)
```

**주의**: launcher는 새 코드로 만든 패키지에만 들어있어요. 어제 돌린 결과엔 없으니, 이 방법을 쓰려면 파이프라인을 새로 한 번 돌려야 합니다.

---

## 방법 B — 수동으로 전체 CUT 한 번에 열기 (지금 있는 결과로 바로 가능)

launcher 없이, 어제 돌린 결과로도 됩니다. `'LATEST'` 대신 특정 PipelineId를 써도 돼요.

```matlab
cfg = st_config();
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, 'LATEST');

% 패키징에 성공한 대상만 추립니다 (실패한 CUT은 모델 파일이 없음)
ok = arrayfun(@(t) ~isempty(t.PackagedStandaloneModel) && ...
    isfile(t.PackagedStandaloneModel), m.Targets);
targets = m.Targets(ok);
fprintf('열 수 있는 CUT: %d / %d\n', numel(targets), numel(m.Targets));

% 같은 이름 모델이 이미 열려있으면 먼저 닫기
for k = 1:numel(targets)
    assert(~bdIsLoaded(targets(k).StandaloneModel), ...
        '이미 열린 모델을 먼저 닫으세요: %s', targets(k).StandaloneModel);
end

% 결과 폴더를 전부 MATLAB path에 등록
folders = cellstr(unique(string({targets.OutputDirectory}), 'stable'));
addpath(folders{:});

% standalone Harness 모델을 전부 load
for k = 1:numel(targets)
    load_system(targets(k).PackagedStandaloneModel);
end

% 패키지 Test File 열기
sltest.testmanager.TestFile(m.TestManagerFile);
sltest.testmanager.view
```

**주의**: 이 방법은 **CVF(커버리지 필터)를 적용하지 않습니다.** Coverage 결과까지 제대로 보려면 방법 A를 쓰거나, 각 Test Case의 Coverage Settings에서 `PackagedCVF` 파일을 직접 지정해야 해요.

다 보신 뒤에는 path를 원래대로 되돌리세요:
```matlab
rmpath(folders{:});
```

---

## 방법 C — 순수 UI 조작만으로

1. MATLAB Current Folder 창에서, Harness `.slx`가 있는 **결과 폴더를 우클릭 → Add to Path → Selected Folders**
2. 그 다음 `TestManager` 폴더의 `.mldatx`를 열기
3. Test Case의 **Model 필드 폴더 버튼**으로 같은 Harness 선택

또는: Model Editor에서 Harness `.slx`를 먼저 열어둔 뒤, Test Manager의 Model 필드에서 그 **모델 이름**을 고르는 방법도 됩니다. 이 동작은 원본 모델이나 원본 Harness를 건드리지 않고 패키지된 standalone Harness만 엽니다.

**주의**: 이 path 등록은 **MATLAB 세션/개인 설정**이라, `.mldatx` 안에 저장되지 않아요. 다른 사람이 같은 결과 폴더를 받아도 한 번은 직접 path에 추가하거나 Harness를 열어줘야 합니다.
