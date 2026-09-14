v2가 요구하는 4개 열(CoverageFilterMode/CoverageBoundaryMode/CoverageFilterAction/CoverageFilterRationale)이 지금 엑셀에 어떻게 되어있는지 전체를 확인해볼게요.

## 해보실 것

```matlab
cfg = st_config();
targets = st_load_targets(false);
T = targets(:, {'No','CUTName','CoverageFilterMode','CoverageBoundaryMode', ...
    'CoverageFilterAction','CoverageFilterRationale'});
disp(T)
```

결과 전체를 캡처해서 보여주세요. (특히 No=1~6번이 다른 행이랑 뭐가 다른지 봐주시면 됩니다.)
