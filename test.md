`cvhtml:ModelNotOpen` 원인 찾았습니다. PACKAGE 단계가 이미 모델이 닫힌 뒤에 `.cvt`(Coverage 결과) 파일을 새로 만들려고 해서 나는 오류였어요. 이제 그 파일도 모델이 열려있는 EXECUTE 단계에서 미리 만들어두도록 고쳤습니다.

## 해보실 것

1. **디버그 설정 해제** (지난번에 켜두신 것 끄기):
```matlab
dbclear all
```

2. `git pull` 로 방금 올라간 수정 받기

3. MATLAB 완전 재시작

4. 처음부터 순서대로 다시:
```matlab
st_setup
st_run_from_harness('PreparationMode','FORCE','ExecutionMode','PER_CUT','ExecuteTests',false)
```

```matlab
cfg = st_config();
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)
end
```

```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

5. 다 끝나면 결과 확인:
```matlab
[code, summary] = st_check_standalone_coverage('PipelineId', info.PipelineId);
disp(code)
disp(info.Status)
```

`info.Status`가 `'OK'`가 아니거나 `code`에 `0`이 섞여 있으면 캡처해서 보여주세요.
