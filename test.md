이 10개 CUT의 `CoverageBoundaryMode`가 진짜 `CUT_ONLY`인지 확인해볼게요.

## 해보실 것

```matlab
t = info.Targets;
idx = find([t.No] >= 26 & [t.No] <= 35);
for k = idx
    fprintf('No=%d | %s | Boundary=%s\n', t(k).No, t(k).CUTName, ...
        char(string(t(k).CoverageBoundaryMode)));
end
```

결과 캡처해서 보여주세요.
