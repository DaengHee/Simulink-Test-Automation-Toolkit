우클릭 대신 MATLAB 명령으로 확인해볼게요. 이 함수(Function Caller)가 실제로 어디 정의돼 있는지 찾는 명령입니다.

## 해보실 것

```matlab
cfg = st_config();
if ~bdIsLoaded(cfg.TopModel)
    load_system(cfg.ModelFile);
end
allBlocks = find_system(cfg.TopModel, 'FindAll', 'on', 'Type', 'block');

callerIdx = strcmp(get_param(allBlocks, 'BlockType'), 'FunctionCaller');
callers = allBlocks(callerIdx);
fprintf('=== Function Caller 블록들 (부르는 쪽) ===\n');
for i = 1:numel(callers)
    fprintf('%s | Prototype=%s\n', getfullname(callers(i)), ...
        get_param(callers(i), 'FunctionPrototype'));
end

subsysIdx = strcmp(get_param(allBlocks, 'BlockType'), 'SubSystem');
subsysBlocks = allBlocks(subsysIdx);
isFunc = strcmp(get_param(subsysBlocks, 'IsSimulinkFunction'), 'on');
funcs = subsysBlocks(isFunc);
fprintf('=== Simulink Function 정의들 (실제 로직 있는 곳) ===\n');
for i = 1:numel(funcs)
    fprintf('%s\n', getfullname(funcs(i)));
end
```

**보실 것**: 위쪽 "Function Caller 블록들"에 `OBC_DM_MON_CHK_SWC_Harness25` 관련 항목이 있을 거예요. 그 `Prototype=` 뒤에 나오는 함수 이름과, 아래쪽 "Simulink Function 정의들" 목록에서 비슷한 이름을 찾아보세요. 그 정의가 있는 경로가 `Harness25` 폴더 **안**인지 **밖**인지가 중요합니다.

결과 전체를 캡처해서 보여주세요.
