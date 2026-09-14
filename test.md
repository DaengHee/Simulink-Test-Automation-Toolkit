Model Explorer 안 열어도 됩니다. Stateflow Chart 안에서 바로 하는 법:

1. 이미 여신 Test Assessment(Stateflow Chart) 창에서, 왼쪽이나 위쪽에 있는 **기호(Symbols) 목록/트리**를 찾으세요. (Stateflow 창 메뉴에서 "Symbols" 또는 "Model Explorer" 버튼이 있을 거예요 — 툴바나 좌측 패널)
2. 그 목록에서 에러 메시지에 나온 그 Input 심볼(`...DTCEnable`로 끝나는 이름) 찾아서 **더블클릭**
3. 속성 창이 뜨면 `Size` 칸 찾기 — 지금 `-1`로 되어있을 거예요
4. `-1`을 지우고 실제 크기 숫자로 입력 (스칼라면 `1`)
5. 적용/OK 누르고 모델 저장

## 다시 실행

```matlab
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```
