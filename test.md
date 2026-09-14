제가 범위를 전체 모델로 잘못 잡아서 관계없는 것까지 다 나왔어요. `Harness25` 하나로만 좁혀서 다시 확인할게요.

## 해보실 것

```matlab
cfg = st_config();
if ~bdIsLoaded(cfg.TopModel)
    load_system(cfg.ModelFile);
end
sltest.harness.open(cfg.TopModel, 'OBC_DM_MON_CHK_SWC_Harness25');

harnessModel = 'OBC_DM_MON_CHK_SWC_Harness25';
allBlocks = find_system(harnessModel, 'FindAll', 'on', 'Type', 'block');

callerIdx = strcmp(get_param(allBlocks, 'BlockType'), 'FunctionCaller');
callers = allBlocks(callerIdx);
fprintf('=== Function Caller 블록들 (Harness25 안) ===\n');
for i = 1:numel(callers)
    fprintf('%s\n  Prototype=%s\n', getfullname(callers(i)), ...
        get_param(callers(i), 'FunctionPrototype'));
end

subsysIdx = strcmp(get_param(allBlocks, 'BlockType'), 'SubSystem');
subsysBlocks = allBlocks(subsysIdx);
isFunc = strcmp(get_param(subsysBlocks, 'IsSimulinkFunction'), 'on');
funcs = subsysBlocks(isFunc);
fprintf('=== Harness25 안에 있는 Simulink Function 정의들 ===\n');
for i = 1:numel(funcs)
    fprintf('%s\n', getfullname(funcs(i)));
end
if isempty(funcs)
    fprintf('(Harness25 안에는 Simulink Function 정의가 하나도 없음)\n');
end
```

결과 그대로 캡처해서 보여주세요. (이번엔 두세 줄 정도로 짧게 나올 거예요.)
