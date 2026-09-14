v2는 엑셀(TestManagement.xlsx)의 아래 4개 열이 **모든 대상(CUT)에서** 다음 값이어야 한다고 강제해요:

| 열 이름 | 요구값 | 뜻 |
|---|---|---|
| `CoverageFilterMode` | `ALL_CONTENT` | CUT 안의 하위 내용까지 전부 측정 대상에 포함 (직계 자식만 보는 `SUBSYSTEM`이 아니라) |
| `CoverageBoundaryMode` | `CUT_ONLY` | CUT 경계 안에서만 측정 (형제 블록 등 바깥은 제외) — 이게 아까 SetCalParm 10개를 0으로 만든 그 설정이에요 |
| `CoverageFilterAction` | `EXCLUDE` | 필터 규칙 걸릴 때 "제외" 처리 (사유만 적고 통과시키는 `JUSTIFY`가 아니라) |
| `CoverageFilterRationale` | (빈 값 금지) | 왜 이렇게 설정했는지 적는 사유 텍스트 칸 |

지금 No=1~6번 CUT은 이 4개 중 하나 이상이 다르게 설정돼 있어서 v2 파이프라인이 시작도 못 하고 막혔습니다.

## 해보실 것

현재 엑셀에 이 4개 열이 실제로 어떻게 되어있는지 전체 확인:

```matlab
cfg = st_config();
targets = st_load_targets(false);
T = targets(:, {'No','CUTName','CoverageFilterMode','CoverageBoundaryMode', ...
    'CoverageFilterAction','CoverageFilterRationale'});
disp(T)
```

결과 전체를 캡처해서 보여주세요. (특히 No=1~6번이 다른 행이랑 뭐가 다른지 봐주시면 됩니다.)
