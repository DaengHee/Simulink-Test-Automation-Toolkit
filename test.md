그 창에는 `.mat`으로 바로 내보내는 옵션이 없어요. 대신 이렇게 2단계로 하시면 됩니다.

## 1. 내보내기 창에서

"내보낼 파일 선택" 목록에서 **`Simulink.io.BaseWorkspace`** 선택하고 확인 누르세요.
→ 지금 체크된 `UT_REQ_SetDT...` 신호(DataSet 형식)가 MATLAB 작업 공간에 변수로 생깁니다.

## 2. MATLAB Command Window에서

방금 생긴 변수 이름을 확인하세요.

```matlab
who
```

목록에서 `UT_REQ_SetDTCFIMEnable...`로 시작하는 변수 이름을 찾은 뒤, 그 이름을 아래에 그대로 넣어서 저장하세요. (아래 `실제변수명` 자리를 바꿔서 입력)

```matlab
save('result\sldv\37_SetDTCFIMEnable\SetDTCFIMEnable0_sldvdata2.mat', '실제변수명')
```

## 3. 엑셀에서

37번 행의 `DataFileFormat` 열을 `MAT`으로 설정해주세요. (없으면 열을 추가하시면 됩니다.)

다 하신 뒤 `who` 결과랑 실제 저장한 변수명 알려주시면 확인해드릴게요.
