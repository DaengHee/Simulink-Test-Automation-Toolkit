function tests = test_standalone_coverage_pipeline
%TEST_STANDALONE_COVERAGE_PIPELINE Static Action workflow contracts.
tests = functiontests(localfunctions);
end

function testControllerUsesActionAPIAndConditionalSavePolicy(testCase)
text = source('pipeline', 'st_run_standalone_coverage_pipeline.m');
verifyTrue(testCase, contains(text, ...
    "addParameter(p, 'Action', 'ALL'"));
verifyTrue(testCase, contains(text, ...
    "{'EXECUTE','PACKAGE','SUMMARY','ALL'}"));
verifyTrue(testCase, contains(text, ...
    "value = strcmp(action, 'EXECUTE')"));
verifyTrue(testCase, contains(text, ...
    "'ExecutionModelMode', 'STANDALONE_HARNESS'"));
verifyTrue(testCase, contains(text, ...
    "'ResultFilterMode', 'POST_RUN_REQUIRED'"));
verifyTrue(testCase, contains(text, ...
    "st_require_runtime_target('LoadModel', false)"));
verifyTrue(testCase, contains(text, "'Version', 2"));
verifyTrue(testCase, contains(text, "'Actions', struct("));
verifyTrue(testCase, contains(text, "'Inputs', {input_inventory(cfg)}"));
verifyTrue(testCase, contains(text, ...
    "'Harnesses', {harness_asset_inventory(cfg)}"));
verifyTrue(testCase, contains(text, ...
    "'RunnerEnvironmentCleanupStatus', 'NOT_RUN'"));
end

function testRemovedOptionsReturnMigrationErrorsBeforeRuntime(testCase)
verifyError(testCase, @() st_run_standalone_coverage_pipeline( ...
    'RunMode', 'STEP234'), ...
    'simtest:StandalonePipelineRunModeRemoved');
verifyError(testCase, @() st_run_standalone_coverage_pipeline( ...
    'Action', 'PACKAGE', 'SaveTestResult', true), ...
    'simtest:StandalonePipelineSaveResultNotAllowed');
verifyError(testCase, @() st_run_standalone_coverage_pipeline( ...
    'Action', 'BOGUS'), 'simtest:StandalonePipelineActionInvalid');
end

function testExecuteUsesOneRunPostRunFilterContract(testCase)
runner = source('execution', 'st_run_tests_per_cut.m');
prepare = source('execution', ...
    'st_prepare_standalone_bundle_execution.m');
verifyTrue(testCase, contains(prepare, ...
    'targets.ExpectedUpdateMode(:) = "OFF"'));
runAt = strfind(runner, 'initialResult = run(tc)');
generateAt = strfind(runner, ...
    'generate_filter(row, filterDirectory, cfg, logPath, i,');
verifyGreaterThanOrEqual(testCase, numel(generateAt), 2);
verifyLessThan(testCase, runAt(1), generateAt(2));
verifyTrue(testCase, contains(runner, "'RUN_START'"));
verifyTrue(testCase, contains(runner, "'RUN_DONE'"));
verifyTrue(testCase, contains(runner, "'CVF_GENERATE'"));
verifyTrue(testCase, contains(runner, "'RESULT_FILTER_ATTACH'"));
verifyTrue(testCase, contains(runner, "'FILTER_RESTORE'"));
verifyTrue(testCase, contains(runner, "'MODEL_CLEANUP'"));
verifyFalse(testCase, contains(runner, ...
    'verify_result_filter_roundtrip'));
end

function testAllUsesLiveResultAndPackageOnlyImportsOnce(testCase)
controller = source('pipeline', ...
    'st_run_standalone_coverage_pipeline.m');
package = source('pipeline', ...
    'st_package_standalone_coverage_artifacts.m');
verifyTrue(testCase, contains(controller, ...
    'outputRoot, manifest, runtimeContext'));
verifyEqual(testCase, numel(regexp(package, ...
    'sltest\.testmanager\.importResults', 'match')), 1);
verifyFalse(testCase, contains(package, ...
    'sltest.testmanager.exportResults'));
verifyFalse(testCase, contains(package, "'ReadOnly', true"));
verifyFalse(testCase, contains(package, 'FilteredResults.mldatx'));
verifyFalse(testCase, contains(package, 'coverage-metrics.mat'));
verifyFalse(testCase, contains(package, 'cvhtml('));
verifyTrue(testCase, contains(package, 'cvsave(arguments{:})'));
verifyEqual(testCase, numel(regexp(package, ...
    'sltest\.testmanager\.report\(', 'match')), 1);
verifyTrue(testCase, contains(package, ...
    "'IncludeCoverageResult', true"));
verifyTrue(testCase, contains(package, "source = 'LIVE'"));
verifyTrue(testCase, contains(package, "source = 'IMPORTED'"));
verifyTrue(testCase, contains(package, ...
    "require_not_started(manifest, 'PACKAGE')"));
summary = source('pipeline', ...
    'st_export_standalone_coverage_summary.m');
verifyTrue(testCase, contains(summary, ...
    "require_not_started(manifest, 'SUMMARY')"));
end

function testSummaryUsesExactSevenColumns(testCase)
text = source('pipeline', ...
    'st_export_standalone_coverage_summary.m');
verifyTrue(testCase, contains(text, ...
    "{'NUM','CUT_NAME','CUT_PATH','Test Case Name','Harness Name', ..."));
verifyTrue(testCase, contains(text, ...
    "'Decision (%)','Execution (%)'"));
verifyFalse(testCase, contains(text, 'MetricSnapshot'));
verifyFalse(testCase, contains(text, 'load('));
[percentage, percentageText] = st_coverage_percentage(0, 0);
verifyTrue(testCase, isnan(percentage));
verifyEqual(testCase, percentageText, "N/A");
end

function testPipelineStateIsAtomicAndV2Only(testCase)
writer = source('pipeline', ...
    'st_write_standalone_pipeline_manifest.m');
loader = source('pipeline', ...
    'st_load_standalone_pipeline_manifest.m');
verifyTrue(testCase, contains(writer, 'tempname(folder)'));
verifyTrue(testCase, contains(writer, "movefile(temporary, path, 'f')"));
verifyTrue(testCase, contains(writer, 'ManifestSHA256'));
verifyTrue(testCase, contains(loader, ...
    'StandalonePipelineManifestChecksumMismatch'));
verifyTrue(testCase, contains(loader, ...
    'StandalonePipelineManifestMigrationRequired'));
end

function testResultFilterFlattensSupportedShapes(testCase)
helper = source('coverage', 'st_flatten_coverage_results.m');
collector = source('coverage', 'st_collect_result_coverage_objects.m');
filter = source('coverage', 'st_apply_result_coverage_filters.m');
verifyTrue(testCase, contains(helper, "isa(value, 'cvdata')"));
verifyTrue(testCase, contains(helper, "isa(value, 'cv.cvdatagroup')"));
verifyTrue(testCase, contains(filter, ...
    'st_collect_result_coverage_objects(resultObj)'));
verifyTrue(testCase, contains(collector, ...
    'st_collect_test_case_results(resultObj)'));
end

function text = source(folder, file)
text = string(fileread(fullfile(st_project_root(), 'src', folder, file)));
end
