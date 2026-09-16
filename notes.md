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

지난번 `simtest:StandalonePipelineHarnessFileMissing: ... OBC_SM_SWC_Harness1` 오류가
아직 안 고쳐졌다면 위 실행은 똑같이 `harness_asset_inventory` 단계에서 막힙니다.
먼저 아래로 모델의 모든 Harness 상태를 확인하세요 (읽기 전용).

```matlab
cfg = st_require_runtime_target();
loadedHere = ~bdIsLoaded(cfg.TopModel);
if loadedHere, load_system(cfg.ModelFile); end
items = sltest.harness.find(cfg.TopModel);
n = numel(items);
Owner = strings(n,1); Name = strings(n,1);
External = false(n,1); FilePathOK = false(n,1);
for i = 1:n
    Owner(i) = string(items(i).ownerFullPath);
    Name(i) = string(items(i).name);
    External(i) = isfield(items,'saveExternally') && logical(items(i).saveExternally);
    if External(i)
        FilePathOK(i) = isfield(items,'harnessFilePath') && ...
            strlength(string(items(i).harnessFilePath)) > 0;
    else
        FilePathOK(i) = true;
    end
end
T = table(Owner, Name, External, FilePathOK);
disp(T)
disp(T(T.External & ~T.FilePathOK, :))
```

마지막 `disp`에 걸리는 행이 "저장 파일 경로가 없는 External Harness"입니다. 그 Harness를
Simulink에서 열어서:
- 계속 외부로 안 써도 되면 Harness 속성에서 "Save harness as separate file" 체크를 끄고
  모델을 다시 저장
- 외부로 써야 하면 Harness를 열고 File > Save As로 실제 경로를 지정해 저장

이 정리가 끝나면 위 "기본 실행" 블록을 돌리세요. 출력 전체를 캡처해서 보여주세요.

## 만약 실행 후 결과를 Test Manager로 열고 싶다면

```matlab
cfg = st_config();
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);
run(m.TestManagerLauncher)
```

`info` 변수가 없으면(MATLAB 재시작 등) `info.PipelineId` 대신 `'LATEST'`를 넣으세요.
