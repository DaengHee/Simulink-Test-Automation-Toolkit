문제되는 CUT들의 정확한 No / Harness 번호를 뽑아볼게요. 제가 로그만 보고 추측하면 틀릴 수 있어서, 지금 세션의 `info` 데이터에서 직접 뽑는 게 정확합니다.

## 해보실 것

```matlab
t = info.Targets;
for k = 1:numel(t)
    if strcmpi(t(k).ExecutionStatus, 'FAIL')
        fprintf('No=%d | Harness=%s | CUT=%s\n', t(k).No, t(k).ExecutionModel, t(k).CUTName);
    end
end
```

나온 결과를 그대로 보여주세요.
