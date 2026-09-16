# 지금 할 일

같은 오류가 진입 방식(직접 호출, `st_run_from_stage`)과 상관없이 계속 나는 걸
보고 원인을 다시 확인했습니다. **이건 명령어 순서 문제가 아니라 모델 자체의
Harness 설정 문제였습니다.** (FORCE를 쓰지 말라는 조언은 여전히 유효합니다 —
다른 이유 때문이지만, 이번 오류의 원인은 아니었습니다.)

## 왜 명령어를 바꿔도 계속 나는지

`harness_asset_inventory`는 EXECUTE가 시작되자마자(다른 어떤 로직보다도 먼저)
**모델에 있는 모든 Harness**를 검사합니다. 이건 어떤 진입점(`st_run_standalone_coverage_pipeline` 직접 호출이든, `st_run_from_stage`로 EXECUTE부터든)을 쓰든 똑같이
실행되는 첫 단계라서, 명령어를 바꿔도 이 검사 자체는 피할 수 없습니다. 그런데도
계속 같은 Harness에서 막힌다는 건 — 그 Harness가 실제로 "외부 파일로 저장"
설정은 켜져 있는데 파일 경로가 없는 상태로 저장돼 있다는 뜻입니다.

## 확인 (지난번에 드렸던 것과 동일, 다시 실행)

```matlab
cfg = st_require_runtime_target();
loadedHere = ~bdIsLoaded(cfg.TopModel);
if loadedHere, load_system(cfg.ModelFile); end
items = sltest.harness.find(cfg.TopModel);
n = numel(items);
Owner = strings(n,1); Name = strings(n,1);
External = false(n,1); FilePathOK = false(n,1);
for i = 1:n
    Owner(i) = string(items(i).ownerFullPath);
    Name(i) = string(items(i).name);
    External(i) = isfield(items,'saveExternally') && logical(items(i).saveExternally);
    if External(i)
        FilePathOK(i) = isfield(items,'harnessFilePath') && ...
            strlength(string(items(i).harnessFilePath)) > 0;
    else
        FilePathOK(i) = true;
    end
end
T = table(Owner, Name, External, FilePathOK);
disp(T)
broken = T(T.External & ~T.FilePathOK, :);
disp(broken)
```

`broken`에 나오는 행들이 지금 파이프라인을 막고 있는 Harness입니다.

## 고치는 방법 (Signal Editor 입력/Assessment는 안 건드림 — 저장 위치 설정만 바꿈)

`broken`에 나온 Harness를 하나씩 Simulink에서 열어서:

```matlab
sltest.harness.open('<CUTPath>', '<HarnessName>');
```

Harness 창이 열리면 **Simulink Test 탭 > Harness > Properties**(또는 Test Manager에서
해당 Harness 우클릭 > Properties)로 들어가서 **"Save harness as separate file"**
체크박스를 확인하세요:
- 외부 파일로 안 쓸 거면: 체크 해제하고 저장
- 외부 파일로 써야 하면: 체크는 유지하고 그 옆 경로 지정(Browse)으로 실제 파일 경로를
  지정해서 저장

이 설정은 Harness의 **저장 위치**만 바꾸는 거라 안에 있는 Signal Editor 시나리오나
Assessment 기대값은 그대로 남습니다. 하나 고치고 저장한 뒤 위 확인 스크립트를 다시
돌려서 `broken`이 줄어드는지 확인하고, 전부 없어질 때까지 반복하세요.

`broken`이 비면 그때 아래를 다시 돌리세요:

```matlab
[ready, checks] = st_check_readiness('Workflow','STANDALONE','FromStage','EXECUTE');
assert(ready.Ready, 'Resolve readiness checks first.');
info = st_run_from_stage('Workflow','STANDALONE','FromStage','EXECUTE');
[code, summary, details] = st_check_standalone_coverage('PipelineId', info.PipelineId);
```

`broken` 목록과, Harness 하나 고친 뒤의 재확인 결과를 캡처해서 보여주세요.
