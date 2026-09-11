이거 실행하고 결과 보내주세요. `{CUT_NAME}`은 실제 이름으로 바꿔서 치세요.

```matlab
cfg = st_require_runtime_target();
handles = find_system(cfg.TopModel, 'FindAll', 'on', 'Name', '{CUT_NAME}');

cutPath = getfullname(handles(1));
disp(cutPath)

children = find_system(cutPath, 'SearchDepth', 1, 'Type', 'Block');
disp(get_param(children, 'BlockType'))

get_param(handles(1), 'MaskType')
```
