SLDV 매니페스트가 오래돼서 마지막 타겟(35/35)에서 실패했습니다. STEP1을 강제로 다시 돌려서 매니페스트부터 갱신해주세요.

```matlab
st_run_standalone_coverage_pipeline('RunMode','STEP1','PreparationMode','FORCE')
```

끝나면 이어서 실행:

```matlab
info = st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')
```
