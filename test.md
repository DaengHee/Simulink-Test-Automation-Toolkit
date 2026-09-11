최신 받고, 출력 경로를 D 드라이브로 지정한 뒤 실행해주세요.

```bash
git pull
```

```matlab
st_setup

% 최초 1회만 (이후엔 계속 유지되니 다시 안 쳐도 됨)
st_set_standalone_coverage_root('D:\stt_work')

info = st_run_standalone_coverage_pipeline('RunMode','STEP2_TO_6')
```

에러 없이 끝까지 도는지 확인해주세요.
