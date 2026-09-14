원인: 해당 CUT의 Test Assessment(Stateflow) Input 심볼 하나가 `Size = -1`(자동/상속)로 되어있습니다. 저희 코드는 이걸 못 읽고, **숫자로 명시된 Size**만 받습니다.

## 고치는 법

1. 방금 에러 메시지에 나온 그 심볼 이름(`...DTCEnable`로 끝나는 것)을 가진 CUT의 Harness를 여세요.
2. Test Assessment(Stateflow Chart) 열기
3. Model Explorer(또는 Symbols 창)에서 해당 Input Data 심볼 찾기
4. 속성 창에서 `Size`를 `-1`에서 **실제 신호 크기에 맞는 숫자**로 변경 (이름상 boolean/flag 같아서 대부분 스칼라면 `1`)
5. 저장

## 다시 실행

```matlab
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```
