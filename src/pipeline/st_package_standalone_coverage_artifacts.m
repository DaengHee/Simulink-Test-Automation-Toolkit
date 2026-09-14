function manifest = st_package_standalone_coverage_artifacts( ...
        outputRoot, manifest, runtimeContext)
%ST_PACKAGE_STANDALONE_COVERAGE_ARTIFACTS Package each live/imported Result.

cfg = st_require_runtime_target('LoadModel', false);
timerValue = tic;
pipelineRoot = fullfile(outputRoot, char(string(manifest.PipelineId)));
st_log(cfg, 'INFO', ...
    'Standalone coverage PACKAGE start | PipelineId=%s', ...
    char(string(manifest.PipelineId)));
require_action(manifest, 'EXECUTE');
require_not_started(manifest, 'PACKAGE');
manifest.Actions.PACKAGE = action_state('RUNNING', ...
    'Packaging live or persisted Result objects');
st_write_standalone_pipeline_manifest(outputRoot, manifest);

[resultRoots, importCount, resultSource] = ...
    resolve_results(manifest, runtimeContext, cfg);
manifest.ResultImportCount = importCount;
manifest.PackageResultSource = resultSource;
manifest = package_test_file(manifest, pipelineRoot);

for i = 1:numel(manifest.Targets)
    item = manifest.Targets(i);
    folderName = sprintf('%03d_%s', round(double(item.No)), ...
        st_export_safe_name(item.CUTName));
    targetDirectory = fullfile(pipelineRoot, folderName);
    if ~isfolder(targetDirectory), mkdir(targetDirectory); end
    item.OutputDirectory = targetDirectory;
    item.TargetManifest = fullfile(targetDirectory, ...
        'target-manifest.json');
    st_log(cfg, 'INFO', ...
        '[PACKAGE %d/%d] start | CUT=%s', ...
        i, numel(manifest.Targets), item.CUTName);
    try
        if strcmpi(item.ExecutionStatus, 'FAIL')
            error('simtest:StandalonePipelineExecuteTargetFailed', ...
                'EXECUTE did not satisfy the target lifecycle contract.');
        end
        resultObj = resolve_target_result(resultRoots, item);
        item = package_target(item, resultObj, targetDirectory, ...
            pipelineRoot, cfg);
        item.PackageStatus = 'OK';
        st_log(cfg, 'INFO', ...
            '[PACKAGE %d/%d] complete | CUT=%s', ...
            i, numel(manifest.Targets), item.CUTName);
    catch ME
        item.PackageStatus = 'FAIL';
        item.Message = append_message(item.Message, ...
            sprintf('%s: %s', ME.identifier, ME.message));
        st_log(cfg, 'ERROR', ...
            '[PACKAGE %d/%d] failed | CUT=%s | %s: %s', ...
            i, numel(manifest.Targets), item.CUTName, ...
            ME.identifier, ME.message);
    end
    write_target_manifest(item.TargetManifest, item);
    manifest.Targets(i) = item;
    manifest.UpdatedAt = timestamp_text();
    st_write_standalone_pipeline_manifest(outputRoot, manifest);
end

status = target_action_status(manifest.Targets, 'PackageStatus');
manifest.Actions.PACKAGE = action_state(status, ...
    'Model, Input, CVF, CVT, and one HTML report packaged per target');
manifest.Status = pipeline_status(manifest);
manifest.UpdatedAt = timestamp_text();
st_log(cfg, 'INFO', ...
    'Standalone coverage PACKAGE complete | Status=%s | elapsed=%.3f sec', ...
    status, toc(timerValue));
end

function [roots, importCount, source] = resolve_results(manifest, context, cfg)
importCount = 0;
source = '';
if isstruct(context) && isfield(context, 'Results') && ...
        ~isempty(context.Results)
    raw = context.Results;
    roots = cell(numel(raw),1);
    for i = 1:numel(raw)
        roots{i} = raw(i).FinalResult;
    end
    st_log(cfg, 'DEBUG', ...
        'PACKAGE is using live Result objects | Targets=%d', numel(roots));
    source = 'LIVE';
    return;
end
if ~isfield(manifest, 'CanResumePackage') || ...
        ~logical(manifest.CanResumePackage) || ...
        ~isfield(manifest, 'ResultFile') || ...
        ~isfile(char(string(manifest.ResultFile)))
    error('simtest:StandalonePipelineResultUnavailable', ...
        ['PACKAGE requires live Result objects from ALL or an EXECUTE run ' ...
         'created with SaveTestResult=true.']);
end
signature = st_file_signature(manifest.ResultFile);
if ~strcmpi(signature.SHA256, char(string(manifest.ResultSHA256)))
    error('simtest:StandalonePipelineResultChecksumMismatch', ...
        'Saved aggregate Result checksum changed: %s', manifest.ResultFile);
end
st_log(cfg, 'INFO', ...
    'PACKAGE aggregate Result import start | File=%s', manifest.ResultFile);
imported = sltest.testmanager.importResults(manifest.ResultFile);
importCount = 1;
source = 'IMPORTED';
roots = cell(numel(imported),1);
for i = 1:numel(imported), roots{i} = imported(i); end
st_log(cfg, 'INFO', ...
    'PACKAGE aggregate Result import complete | Roots=%d', numel(roots));
end

function resultObj = resolve_target_result(roots, item)
matches = false(numel(roots),1);
for i = 1:numel(roots)
    cases = st_collect_test_case_results(roots{i});
    names = strings(numel(cases),1);
    for j = 1:numel(cases)
        try, names(j) = string(cases{j}.Name); catch, end
    end
    matches(i) = any(names == string(item.TestCaseName));
end
indices = find(matches);
if numel(indices) ~= 1
    error('simtest:StandalonePipelineResultMappingAmbiguous', ...
        'Expected one Result root for Test Case %s, found %d.', ...
        item.TestCaseName, numel(indices));
end
resultObj = roots{indices};
end

function manifest = package_test_file(manifest, pipelineRoot)
testManagerDirectory = fullfile(pipelineRoot, 'TestManager');
if ~isfolder(testManagerDirectory), mkdir(testManagerDirectory); end
if ~isfile(manifest.TestManagerWorkFile)
    error('simtest:StandalonePipelineTestFileMissing', ...
        'Rewired working Test File is missing: %s', ...
        char(string(manifest.TestManagerWorkFile)));
end
[~, name, extension] = fileparts(manifest.TestManagerWorkFile);
destination = fullfile(testManagerDirectory, [name extension]);
copy_checked(manifest.TestManagerWorkFile, destination);
manifest.TestManagerFile = destination;
manifest.TestManagerSHA256 = st_file_signature(destination).SHA256;
end

function item = package_target(item, resultObj, targetDirectory, ...
        pipelineRoot, cfg)
item = package_execution_inputs(item, targetDirectory, cfg);
sourceCVF = item.ExecutionCVFPath;
if ~isfile(sourceCVF)
    error('simtest:StandalonePipelineCVFMissing', ...
        'Generated CVF is missing: %s', sourceCVF);
end
finalCVF = fullfile(targetDirectory, ...
    [st_export_safe_name(item.CUTName) '_CoverageFilter.cvf']);
copy_checked(sourceCVF, finalCVF);
item.PackagedCVF = finalCVF;
item.PackagedCVFSHA256 = st_file_signature(finalCVF).SHA256;

coverageObjects = st_collect_result_coverage_objects(resultObj);
if isempty(coverageObjects)
    error('simtest:StandalonePipelineCoverageMissing', ...
        'Result contains no coverage objects.');
end
cvtPath = fullfile(targetDirectory, ...
    [st_export_safe_name(item.CUTName) '_CoverageResult.cvt']);
delete_if_present(cvtPath);
st_log(cfg, 'DEBUG', 'PACKAGE cvsave start | CUT=%s', item.CUTName);
save_cvt(cvtPath, coverageObjects, cfg);
st_log(cfg, 'DEBUG', 'PACKAGE cvsave complete | CUT=%s', item.CUTName);
item.CoverageResult = cvtPath;
item.CoverageResultSHA256 = st_file_signature(cvtPath).SHA256;

item = package_official_report_and_metrics( ...
    item, resultObj, targetDirectory, pipelineRoot, cfg);
end

function item = package_official_report_and_metrics( ...
        item, resultObj, targetDirectory, pipelineRoot, cfg)
modelName = char(string(item.StandaloneModel));
modelFile = char(string(item.StandaloneModelFile));
if ~isfile(modelFile)
    error('simtest:StandalonePipelineReportModelMissing', ...
        'Execution standalone model is missing: %s', modelFile);
end
if bdIsLoaded(modelName)
    loadedFile = char(string(get_param(modelName, 'FileName')));
    st_log(cfg, 'ERROR', ...
        ['PACKAGE report model isolation failed | CUT=%s | ' ...
         'Model=%s | LoadedFile=%s'], ...
        item.CUTName, modelName, loadedFile);
    error('simtest:StandalonePipelineReportModelAlreadyLoaded', ...
        ['Model %s is already loaded before PACKAGE report generation. ' ...
         'The loaded model was not closed or replaced: %s'], ...
        modelName, loadedFile);
end

state = containers.Map();
state('CloseRequired') = true;
modelCleanup = onCleanup(@() ...
    cleanup_report_model_context_quietly( ...
        state, modelName, item.CUTName, cfg)); %#ok<NASGU>
try
    st_log(cfg, 'INFO', ...
        'PACKAGE report model open start | CUT=%s | File=%s', ...
        item.CUTName, modelFile);
    load_system(modelFile);
    loadedFile = char(string(get_param(modelName, 'FileName')));
    if ~same_path(loadedFile, modelFile)
        error('simtest:StandalonePipelineReportModelLoadMismatch', ...
            ['PACKAGE loaded a different standalone model file. ' ...
             'Expected=%s | Actual=%s'], modelFile, loadedFile);
    end
    st_log(cfg, 'INFO', ...
        'PACKAGE report model open complete | CUT=%s | Model=%s', ...
        item.CUTName, modelName);

    reportDirectory = fullfile(targetDirectory, ...
        [st_export_safe_name(item.CUTName) '_TestReport']);
    if isfolder(reportDirectory), rmdir(reportDirectory, 's'); end
    mkdir(reportDirectory);
    zipDirectory = fullfile(pipelineRoot, '.work', 'package');
    if ~isfolder(zipDirectory), mkdir(zipDirectory); end
    zipPath = fullfile(zipDirectory, sprintf('%03d_TestReport.zip', ...
        round(double(item.No))));
    delete_if_present(zipPath);
    st_log(cfg, 'INFO', ...
        'PACKAGE Test Manager HTML report start | CUT=%s', item.CUTName);
    sltest.testmanager.report(resultObj, zipPath, ...
        'Title', [item.CUTName ' Test Report'], ...
        'IncludeMLVersion', true, ...
        'IncludeTestResults', int32(0), ...
        'IncludeCoverageResult', true, ...
        'IncludeSimulationMetadata', true, ...
        'LaunchReport', false);
    unzip(zipPath, reportDirectory);
    ensure_report_html(reportDirectory);
    item.TestReport = reportDirectory;
    item.ReportHTML = fullfile(reportDirectory, 'report.html');
    st_log(cfg, 'INFO', ...
        'PACKAGE Test Manager HTML report complete | CUT=%s', ...
        item.CUTName);

    target = table(item.No, string(item.CUTName), ...
        string(item.CUTPath), string(item.TestCaseName), ...
        string(item.StandaloneCUTPath), ...
        'VariableNames', {'No','CUTName','CUTPath','TestCaseName', ...
        'StandaloneCUTPath'});
    metrics = st_collect_final_cut_coverage_metrics( ...
        resultObj, target, 'LogConfig', cfg);
    item = assign_metric(item, metrics.Decision, 'Decision');
    item = assign_metric(item, metrics.Execution, 'Execution');
    item.MetricSource = metrics.Source;
    item.MetricSourceStatus = metrics.SourceStatus;
    if strcmp(metrics.SourceStatus, 'AMBIGUOUS')
        error('simtest:StandalonePipelineMetricAmbiguous', ...
            'Coverage metric source is ambiguous for %s.', item.CUTName);
    end

    close_report_model_context(state, modelName, item.CUTName, cfg);
    clear modelCleanup;
catch ME
    st_log(cfg, 'ERROR', ...
        'PACKAGE report context failed | CUT=%s | %s: %s', ...
        item.CUTName, ME.identifier, ME.message);
    try
        close_report_model_context(state, modelName, item.CUTName, cfg);
    catch closeME
        ME = addCause(ME, closeME);
    end
    clear modelCleanup;
    rethrow(ME);
end
end

function close_report_model_context(state, modelName, cutName, cfg)
if ~state('CloseRequired'), return; end
st_log(cfg, 'INFO', ...
    'PACKAGE report model close start | CUT=%s | Model=%s', ...
    cutName, modelName);
try
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    if bdIsLoaded(modelName)
        error('simtest:StandalonePipelineReportModelStillLoaded', ...
            'Model remains loaded after PACKAGE report generation: %s', ...
            modelName);
    end
    state('CloseRequired') = false;
    st_log(cfg, 'INFO', ...
        'PACKAGE report model close complete | CUT=%s | Model=%s', ...
        cutName, modelName);
catch ME
    st_log(cfg, 'ERROR', ...
        'PACKAGE report model close failed | CUT=%s | %s: %s', ...
        cutName, ME.identifier, ME.message);
    cleanupError = MException( ...
        'simtest:StandalonePipelineReportModelCleanupFailed', ...
        'Cannot close PACKAGE report model %s: %s', ...
        modelName, ME.message);
    cleanupError = addCause(cleanupError, ME);
    throw(cleanupError);
end
end

function cleanup_report_model_context_quietly( ...
        state, modelName, cutName, cfg)
if ~state('CloseRequired'), return; end
try
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    state('CloseRequired') = false;
catch ME
    st_log(cfg, 'WARN', ...
        ['PACKAGE report model fallback cleanup failed | CUT=%s | ' ...
         '%s: %s'], cutName, ME.identifier, ME.message);
end
end

function item = package_execution_inputs(item, targetDirectory, cfg)
st_log(cfg, 'DEBUG', ...
    'PACKAGE standalone inputs start | CUT=%s', item.CUTName);
if ~isfile(item.StandaloneModelFile)
    error('simtest:StandalonePipelineModelMissing', ...
        'Standalone model is missing: %s', item.StandaloneModelFile);
end
[~, modelName, extension] = fileparts(item.StandaloneModelFile);
if ~strcmp(modelName, item.HarnessName) || ...
        ~strcmp(modelName, item.StandaloneModel)
    error('simtest:StandalonePipelineModelNameMismatch', ...
        'Harness, standalone model, and file stem must match for %s.', ...
        item.CUTName);
end
modelDestination = fullfile(targetDirectory, [modelName extension]);
copy_checked(item.StandaloneModelFile, modelDestination);
item.PackagedStandaloneModel = modelDestination;

if isempty(item.SignalEditorInput)
    item.PackagedInputReadbackStatus = 'NOT_REQUIRED';
else
    if ~isfile(item.SignalEditorInput)
        error('simtest:StandalonePipelineInputMissing', ...
            'Standalone input is missing: %s', item.SignalEditorInput);
    end
    [~, inputName, inputExtension] = fileparts(item.SignalEditorInput);
    inputDestination = fullfile(targetDirectory, ...
        [inputName inputExtension]);
    copy_checked(item.SignalEditorInput, inputDestination);
    item.PackagedInput = inputDestination;
    item.PackagedInputSHA256 = st_file_signature(inputDestination).SHA256;
    item = rewire_packaged_input(item, [inputName inputExtension], cfg);
end
item.PackagedStandaloneModelSHA256 = ...
    st_file_signature(modelDestination).SHA256;
st_log(cfg, 'DEBUG', ...
    'PACKAGE standalone inputs complete | CUT=%s', item.CUTName);
end

function item = rewire_packaged_input(item, relativeInput, cfg)
modelFile = item.PackagedStandaloneModel;
modelName = item.StandaloneModel;
folder = fileparts(modelFile);
if bdIsLoaded(modelName)
    loadedFile = char(string(get_param(modelName, 'FileName')));
    st_log(cfg, 'ERROR', ...
        ['PACKAGE input readback model isolation failed | CUT=%s | ' ...
         'Model=%s | LoadedFile=%s'], ...
        item.CUTName, modelName, loadedFile);
    error('simtest:StandalonePipelineModelIsolationFailed', ...
        ['Model %s is already loaded before PACKAGE readback. ' ...
         'The loaded model was not closed or replaced: %s'], ...
        modelName, loadedFile);
end
previousDirectory = pwd;
cleanup = onCleanup(@() restore_model_context( ...
    modelName, previousDirectory)); %#ok<NASGU>
cd(folder);
load_system(modelFile);
block = st_find_signal_editor_block(modelName);
set_param(block, 'Filename', relativeInput);
save_system(modelName);
actual = char(string(get_param(block, 'Filename')));
if ~strcmp(actual, relativeInput)
    error('simtest:StandalonePipelineInputReadbackFailed', ...
        'Packaged Input path readback failed for %s.', item.CUTName);
end
close_system(modelName, 0);
item.PackagedInputReadbackStatus = 'OK';
st_log(cfg, 'DEBUG', ...
    'PACKAGE relative Input readback complete | CUT=%s | Input=%s', ...
    item.CUTName, relativeInput);
end

function restore_model_context(modelName, directory)
try
    if bdIsLoaded(modelName), close_system(modelName, 0); end
catch
end
cd(directory);
end

function item = assign_metric(item, metric, name)
item.([name 'Covered']) = double(metric.Covered);
item.([name 'Total']) = double(metric.Total);
item.([name 'Percentage']) = double(metric.Percentage);
item.([name 'PercentageText']) = char(string(metric.PercentageText));
item.([name 'MetricStatus']) = char(string(metric.Status));
end

function save_cvt(path, objects, cfg)
[folder, name] = fileparts(path);
base = fullfile(folder, name);
arguments = [{base}; objects(:)];
writableCleanup = st_enter_writable_coverage_directory(cfg, 'CVSAVE');
cvsave(arguments{:});
clear writableCleanup;
if ~isfile(path)
    error('simtest:StandalonePipelineCVTSaveMissing', ...
        'cvsave did not create the expected file: %s', path);
end
end

function ensure_report_html(reportDirectory)
rootReport = fullfile(reportDirectory, 'report.html');
if isfile(rootReport), return; end
matches = dir(fullfile(reportDirectory, '**', 'report.html'));
if isempty(matches)
    error('simtest:StandalonePipelineHTMLReportMissing', ...
        'The official Test Manager ZIP contains no report.html.');
end
sourceFolder = matches(1).folder;
entries = dir(sourceFolder);
entries = entries(~ismember({entries.name}, {'.','..'}));
for i = 1:numel(entries)
    source = fullfile(entries(i).folder, entries(i).name);
    destination = fullfile(reportDirectory, entries(i).name);
    if entries(i).isdir
        [ok, message] = copyfile(source, destination, 'f');
        if ~ok
            error('simtest:StandalonePipelineReportCopyFailed', ...
                'Cannot copy report resource %s: %s', source, message);
        end
    else
        copy_checked(source, destination);
    end
end
if ~isfile(rootReport)
    error('simtest:StandalonePipelineHTMLReportMissing', ...
        'Cannot place report.html at the Test Report root.');
end
end

function require_action(manifest, name)
if double(manifest.Version) ~= 2 || ~isfield(manifest, 'Actions') || ...
        ~isfield(manifest.Actions, name) || ...
        ~ismember(upper(string(manifest.Actions.(name).Status)), ["OK","WARN"])
    error('simtest:StandalonePipelineActionNotReady', ...
        '%s must complete before PACKAGE.', name);
end
end

function require_not_started(manifest, name)
if ~isfield(manifest, 'Actions') || ~isfield(manifest.Actions, name) || ...
        ~strcmpi(char(string(manifest.Actions.(name).Status)), 'NOT_RUN')
    error('simtest:StandalonePipelineActionAlreadyStarted', ...
        ['%s can run only once per pipeline. Start a new EXECUTE action ' ...
         'instead of regenerating lifecycle artifacts.'], name);
end
end

function copy_checked(source, destination)
parent = fileparts(destination);
if ~isfolder(parent), mkdir(parent); end
[ok, message] = copyfile(source, destination, 'f');
if ~ok || ~isfile(destination)
    error('simtest:StandalonePipelineCopyFailed', ...
        'Cannot copy %s to %s: %s', source, destination, message);
end
end

function tf = same_path(left, right)
left = char(java.io.File(char(left)).getCanonicalPath());
right = char(java.io.File(char(right)).getCanonicalPath());
if ispc
    tf = strcmpi(left, right);
else
    tf = strcmp(left, right);
end
end

function write_target_manifest(path, item)
temporary = [tempname(fileparts(path)) '.json'];
cleanup = onCleanup(@() delete_if_present(temporary)); %#ok<NASGU>
fileId = fopen(temporary, 'w', 'n', 'UTF-8');
if fileId < 0
    error('simtest:StandaloneTargetManifestWriteFailed', ...
        'Cannot write target manifest: %s', path);
end
fileCleanup = onCleanup(@() fclose(fileId));
fprintf(fileId, '%s\n', jsonencode(item, 'PrettyPrint', true));
clear fileCleanup;
[ok, message] = movefile(temporary, path, 'f');
if ~ok
    error('simtest:StandaloneTargetManifestWriteFailed', ...
        'Cannot replace target manifest: %s', message);
end
end

function delete_if_present(path)
if isfile(path), delete(path); end
end

function value = append_message(existing, added)
if isempty(existing), value = added; else, value = [existing ' | ' added]; end
end

function value = action_state(status, message)
value = struct('Status', status, 'Message', message, ...
    'UpdatedAt', timestamp_text());
end

function status = target_action_status(targets, field)
values = upper(string({targets.(field)}));
if any(values == "FAIL" | values == "SKIP")
    status = 'WARN';
else
    status = 'OK';
end
end

function status = pipeline_status(manifest)
names = fieldnames(manifest.Actions);
values = strings(numel(names),1);
for i = 1:numel(names)
    values(i) = upper(string(manifest.Actions.(names{i}).Status));
end
if any(values == "FAIL")
    status = 'FAIL';
elseif any(values == "WARN" | values == "NOT_RUN")
    status = 'PARTIAL';
else
    status = 'OK';
end
end

function value = timestamp_text()
value = char(datetime('now', ...
    'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX'));
end
