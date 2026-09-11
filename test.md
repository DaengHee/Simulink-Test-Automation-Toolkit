원인 찾았고 코드 수정 완료했습니다. `dev` 브랜치에 있어요 (`test`엔 없음).

1. `dev` 브랜치로 전환하고 최신으로 받기

```bash
git checkout dev
git pull
```

2. MATLAB에서 다시 설정하고 재실행

```matlab
st_setup
st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')
```

전에 났던 `Missing dependencies: {CUT_NAME}` 에러 없이 넘어가는지 확인해주세요.
