2단계에서 `PACKAGE` 중 `cvhtml:ModelNotOpen` 오류의 정확한 발생 지점을 코드만 봐서는 못 찾았습니다. 실제로 멈춰서 스택을 봐야 합니다. 1단계(준비)는 이미 끝났으니 다시 안 하셔도 됩니다.

## 해보실 것 (순서대로)

1. **정확히 이 오류에서만 멈추도록 설정** (이번 1번만):
```matlab
dbclear all
dbstop if caught error Slvnv:simcoverage:cvhtml:ModelNotOpen
```
(`dbstop if caught error`만 쓰면 관련 없는 다른 캐치 오류에서도 다 멈추니, 반드시 위처럼 오류 ID를 붙여주세요.)

2. **모델 닫기** (1.5단계, 2단계 실행 전 필수):
```matlab
cfg = st_config();
if bdIsLoaded(cfg.TopModel)
    close_system(cfg.TopModel, 0)
end
```

3. **Standalone Coverage 실행** (2단계, 34개 CUT 처리 — 시간 걸림):
```matlab
info = st_run_standalone_coverage_pipeline('Action','ALL')
```

4. **`cvhtml:ModelNotOpen`에서 멈추면**:
   - Command Window에 아래 입력해서 나온 결과를 캡처해서 보여주세요:
     ```matlab
     dbstack
     ```
   - 확인 후 계속 진행하려면:
     ```matlab
     dbcontinue
     ```
   - 다 끝나고 나서(또는 그만 멈추게 하려면):
     ```matlab
     dbclear all
     ```
