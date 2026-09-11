확인됐습니다. 엑셀은 `.mat`으로 맞게 고치셨는데, 매니페스트(캐시)는 아직 예전 `.xlsx` 값 그대로 남아있어서 그래요.

```
엑셀 현재 값     : ...SetDTCFIMEnable0_sldvdata2.mat   (맞음)
매니페스트 기록값 : ...SetDTCFIMEnable0_sldvdata2.xlsx  (예전 값, 아직 갱신 안 됨)
```

STEP1을 강제로 다시 돌려서 매니페스트를 지금 엑셀 값으로 갱신해주세요.

```matlab
st_run_standalone_coverage_pipeline('RunMode','STEP1','PreparationMode','FORCE')
```

성공하면 이어서:

```matlab
info = st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')
```
