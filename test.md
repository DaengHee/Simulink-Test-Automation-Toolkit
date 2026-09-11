이거 실행하고 결과 보내주세요. `{CUT_NAME}`은 실제 이름으로 바꿔서 치세요.

```matlab
sfunBlocks = find_system(cutPath, 'SearchDepth', 1, 'BlockType', 'S-Function');
get_param(sfunBlocks, 'FunctionName')
```

(`cutPath` 변수는 아까 실행한 세션에 이미 있을 겁니다. 없으면 이거 먼저 치세요:
`cutPath = getfullname(handles(1));`)
