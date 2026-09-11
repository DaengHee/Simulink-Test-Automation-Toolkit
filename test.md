# 다음에 실행할 것

이어서 확인해야 할 명령어 모음입니다. `{CUT_NAME}`은 실제 CUT/블록 이름 자리입니다
(기밀이라 여기 안 적음. MATLAB에서 실행할 땐 실제 이름으로 바꿔서 치세요).

## 지금까지 확인된 것 (원인 후보 제거됨)

- Model Reference 아님 (BlockType = SubSystem)
- 라이브러리 링크 아님 (ReferenceBlock = '')

## 다음 확인 명령

```matlab
cfg = st_require_runtime_target();
handles = find_system(cfg.TopModel, 'FindAll', 'on', 'Name', '{CUT_NAME}');

cutPath = getfullname(handles(1));
disp(cutPath)

children = find_system(cutPath, 'SearchDepth', 1, 'Type', 'Block');
disp(get_param(children, 'BlockType'))

get_param(handles(1), 'MaskType')
```

## 뭘 보려는 건지

- `children`의 `BlockType` 목록 → 이 CUT 안에 S-Function, MATLAB System, Stateflow Chart
  같은 "별도 파일을 참조하는 블록"이 있는지 확인
- `MaskType` → Variant Subsystem인지 확인 (Variant는 비활성 선택지가 없는 파일을
  참조하고 있을 수 있음)

결과 나오면 캡처해서 보내주시면 원인 계속 좁혀드릴게요.
