엑셀 `SldvDataFile`을 고치셨으니, STEP1을 다시 강제로 돌려서 매니페스트부터 갱신해주세요. (엑셀 값을 바꿀 때마다 매번 STEP1을 다시 돌려야 합니다.)

```matlab
st_run_standalone_coverage_pipeline('RunMode','STEP1','PreparationMode','FORCE')
```

성공하면 이어서:

```matlab
info = st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')
```

STEP1에서도 실패하면, 아까처럼 이 파일 열어서 `Status=FAIL` 줄의 `Message` 내용 보내주세요.

```
result\reports\SldvGenerationResult.ini
```
