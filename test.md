`test` 브랜치를 원본 v2 최신 상태로 맞췄습니다. v2의 새 기능(빈 coverage → N/A 처리, 실패 스택 기록, 원본 Coverage HTML 패키징, Test Manager 실행기)이 다 들어왔고, v2에 없는 `PartAlreadyWritten` 수정은 그대로 유지했습니다.

## 해보실 것 (순서대로)

1. **브랜치 확인** — 반드시 `test`여야 합니다:
```bash
git checkout test
git pull
```

2. **MATLAB 완전 재시작** (새 파일이 여러 개 들어와서 필요해요)

3. **원본 Top Model과 Test File을 저장하고 닫은 뒤**, 아래를 한 번에 복붙:
```matlab
st_setup;
cfg = st_require_runtime_target('LoadModel', false);
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)
end
info = st_run_standalone_coverage_pipeline( ...
    'Action', 'ALL', ...
    'ContinueOnFailure', true, ...
    'FailOnNonPass', false);
```

4. **결과 확인**:
```matlab
[code, summary, details] = st_check_standalone_coverage('PipelineId', info.PipelineId);
disp(code)
disp(summary)
```

성공 기준은 `code = '1111111111'`입니다.

## 참고

- 지난번 v2에서 났던 `Every pipeline target requires ALL_CONTENT + CUT_ONLY + EXCLUDE...` 오류는 **`test` 브랜치에도 똑같이 있는 검사**입니다 (v2가 새로 넣은 게 아님). 엑셀의 No=1~6번 행이 이 조건에 안 맞아서 나는 거라, 그 오류가 또 나면 엑셀을 고쳐야 합니다.
- SetCalParm 10개(Harness25~34)는 v2의 "빈 coverage → N/A" 수정으로 통과할 수도 있어요. 이번 실행에서 확인됩니다.
