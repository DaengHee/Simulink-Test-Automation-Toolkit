`cvhtml:ModelNotOpen`은 해결됐습니다 (PACKAGE 자체는 이제 잘 됩니다). 지금 남은 문제는 다른 거예요: `SetCalParm_` 계열 CUT 6개가 EXECUTE(실제 테스트 실행) 단계에서 아예 실패했어요. 재시작/재실행 필요 없고, 이미 끝난 결과에서 원인만 확인하면 됩니다.

## 해보실 것

아래 그대로 복붙해서 실행해주세요 (지금 세션의 `info` 변수 그대로 사용):

```matlab
t = info.Targets;
for k = 1:numel(t)
    if strcmpi(t(k).ExecutionStatus, 'FAIL')
        fprintf('[%d] %s : %s\n', k, t(k).CUTName, t(k).Message);
    end
end
```

나온 결과를 캡처해서 보여주세요.
