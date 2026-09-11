그 `.mat` 파일 안에 실제로 뭐가 들어있는지 확인해주세요.

```matlab
whos('-file', 'result\sldv\37_SetDTCFIMEnable\SetDTCFIMEnable0_sldvdata2.mat')
```

결과로 나오는 변수 이름(Name)과 타입(Class) 목록을 보내주세요.

## 왜 이걸 확인하는지

`SldvDataFile`은 기본적으로 SLDV 전용 형식(`sldvData`라는 이름의 특정 구조체)을 기대합니다. 지금 파일은 그 형식이 아닌 것 같아요.

만약 이 파일이 `Simulink.SimulationData.Dataset` 타입 변수를 담고 있다면(SLDV가 아니라 일반 MAT Dataset이라면), 엑셀에서 이 행의 `DataFileFormat` 열을 `MAT`으로 설정하면 될 수 있습니다. `whos` 결과 보내주시면 정확히 알려드릴게요.
