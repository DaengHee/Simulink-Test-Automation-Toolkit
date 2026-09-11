정확히 뭐가 안 맞는지 비교해봐야 합니다. 아래 명령 실행해서 결과 보내주세요.

```matlab
cfg = st_require_runtime_target();
targets = st_load_targets(false);
row = targets(targets.No == 37, :);
fprintf('엑셀 현재 값 : [%s]\n', char(row.SldvDataFile));

loaded = load(cfg.SldvManifestFile, 'manifest');
found = false;
for i = 1:numel(loaded.manifest.Profiles)
    p = loaded.manifest.Profiles(i);
    if double(p.No) == 37
        found = true;
        fprintf('매니페스트 기록값 : [%s]\n', p.RequestedDataFile);
        fprintf('매니페스트 Status : %s\n', p.Status);
        fprintf('매니페스트 Message: %s\n', p.Message);
    end
end
if ~found
    fprintf('매니페스트에 No=37 항목 자체가 없습니다.\n');
end
```

**중요**: 이거 실행하기 전에, 엑셀 수정한 뒤 `st_run_standalone_coverage_pipeline('RunMode','STEP1','PreparationMode','FORCE')`를 다시 실행하셨는지도 확인해주세요. 혹시 그 단계를 건너뛰고 바로 STEP2_TO_6를 돌리신 거라면, 그게 원인일 수 있습니다.
