# Standalone Coverage Runtime Commands

이 문서는 실제 MATLAB R2025b에서 실행할 명령만 모아 둔 수동 검증용 runbook이다.
각 블록은 위에서 아래 순서로 복사해 실행한다. 새 코드가 반영된 뒤에는 이전
PipelineId를 재사용하지 말고 새 `ALL` 실행을 만든다.

## 1. 새 파이프라인 실행

원본 Top Model과 Test File을 저장한 뒤 Top Model을 닫는다. MATLAB을 다시 시작한
직후에는 아래 블록만 실행하면 된다.

```matlab
st_setup;
cfg = st_require_runtime_target('LoadModel', false);
assert(~bdIsLoaded(cfg.TopModel), ...
    '원본 Top Model을 저장하고 닫은 후 다시 실행하세요.');

packageFile = which('st_package_standalone_coverage_artifacts');
perCutFile = which('st_run_tests_per_cut');
fprintf('PACKAGE source: %s\n', packageFile);
fprintf('PER_CUT source: %s\n', perCutFile);
assert(contains(fileread(packageFile), ...
    'PACKAGE captured coverage data promotion complete'), ...
    '최신 PACKAGE helper가 아닙니다. 최신 브랜치를 pull한 경로에서 st_setup을 다시 실행하세요.');
assert(contains(fileread(packageFile), ...
    'item.PackageFailure = package_failure_detail(ME)'), ...
    'PACKAGE failure stack 기록 코드가 없습니다. 최신 브랜치를 pull하세요.');
assert(contains(fileread(perCutFile), ...
    'save_package_evidence_cvt(cvtPath, coverageObjects, cfg)'), ...
    '열린 모델에서 CVT evidence를 만드는 최신 PER_CUT 코드가 아닙니다.');
assert(contains(fileread(perCutFile), ...
    'cvhtml(reportHTML, coverageObjects{1}, ''-sRT=0'')'), ...
    'Test Manager Coverage Results 원본 HTML을 만드는 최신 PER_CUT 코드가 아닙니다.');

info = st_run_standalone_coverage_pipeline( ...
    'Action', 'ALL', ...
    'ContinueOnFailure', true, ...
    'FailOnNonPass', false);

[code, summary, details] = st_check_standalone_coverage( ...
    'PipelineId', info.PipelineId);
disp(code)
disp(summary)
disp(details)
```

성공 기준은 `code = '1111111111'` 및 `summary.Status = 'PASS'`다.

## 2. PACKAGE 실패 시 호출 위치 확인

새 실행의 PACKAGE가 실패하면, 다음 블록으로 실패 원인과 최초 호출 파일·라인을
확인한다. `disp`에는 표 하나만 전달한다. `PackageFailure`가 없다는 출력은 그
PipelineId가 최신 PACKAGE helper로 생성되지 않았다는 증거다.

```matlab
[m, manifestPath] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);

fprintf('Manifest: %s\n', manifestPath);
T = struct2table(m.Targets);
disp(T(:, {'CUTName', 'ExecutionStatus', 'PackageEvidenceStatus', ...
    'PackageStatus', 'Message'}));

for k = 1:numel(m.Targets)
    if ~isfield(m.Targets, 'PackageFailure')
        fprintf('\n[%03d] %s: PackageFailure field is absent.\n', ...
            k, m.Targets(k).CUTName);
        continue;
    end
    f = m.Targets(k).PackageFailure;
    if strlength(string(f.Identifier)) == 0
        continue;
    end
    fprintf('\n[%03d] %s\n%s: %s\n', k, m.Targets(k).CUTName, ...
        f.Identifier, f.Message);
    if isfield(f, 'Stack') && ~isempty(f.Stack)
        fprintf('Caller: %s (%s:%d)\n', f.Stack(1).Name, ...
            f.Stack(1).File, f.Stack(1).Line);
    end
end
```

`PackageEvidenceStatus='OK'`이면 열린 execution standalone model에서 Test Manager
Coverage Results의 REPORT 화살표가 여는 원본 `cvhtml` HTML ZIP, metric, CVT evidence까지
생성된 상태다. 이후 PACKAGE는 해당 evidence를 SHA-256으로 검증해 결과 폴더로 복사만
한다.

## 3. B7 metric 실패 확인

checker가 `1111110111`을 반환하면 PACKAGE는 성공했고 B7만 실패한 상태다. 다음
블록으로 Result Coverage API에서 선택한 metric source와 두 metric의 scalar 계약을
확인한다.

```matlab
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);

T = struct2table(m.Targets);
metricColumns = {'CUTName', 'MetricSource', 'MetricSourceStatus', ...
    'DecisionMetricStatus', 'DecisionCovered', 'DecisionTotal', ...
    'DecisionPercentage', 'DecisionPercentageText', ...
    'ExecutionMetricStatus', 'ExecutionCovered', 'ExecutionTotal', ...
    'ExecutionPercentage', 'ExecutionPercentageText'};
disp(T(:, metricColumns));
```

정상값은 `MetricSourceStatus='PROVISIONAL'`, 각 `MetricStatus='OK'`다. CVF가 해당
CUT의 objective를 모두 제외했거나 원래 objective가 없으면 `Covered=0`, `Total=0`,
`Percentage=NaN`, `PercentageText='N/A'`도 정상이다. 반대로 `MISSING`, `INCOMPLETE`,
`AMBIGUOUS`, Total이 0이 아닌데 `NaN`, 혹은 Covered가 Total보다 큰 값이 보이면 표
전체를 공유한다.

## 4. 산출물 확인

```matlab
[m, ~] = st_load_standalone_pipeline_manifest( ...
    cfg.StandaloneCoverageRootDir, info.PipelineId);

for k = 1:numel(m.Targets)
    t = m.Targets(k);
    fprintf('[%03d] %s\n', k, t.CUTName);
    fprintf('  report.html: %d  %s\n', isfile(t.ReportHTML), t.ReportHTML);
    fprintf('  CVT:         %d  %s\n', isfile(t.CoverageResult), t.CoverageResult);
    fprintf('  model closed: %d\n', ~bdIsLoaded(t.StandaloneModel));
end
```

`report.html`, `.cvt`가 모두 존재하고 각 `model closed` 값이 `1`이면 PACKAGE와
cleanup 산출물 계약을 만족한다.
