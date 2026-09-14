% OPEN_STANDALONE_COVERAGE_TEST_MANAGER Open a packaged standalone test file.
%
% This script is packaged beside the MLDATX file. It resolves every
% standalone model and its colocated input before Test Manager refreshes the
% Model SUT properties, then applies each packaged CVF to the in-memory copy.

launcherDirectory = fileparts(mfilename('fullpath'));
pipelineRoot = fileparts(launcherDirectory);
manifestPath = fullfile(pipelineRoot, 'pipeline-manifest.json');
if ~isfile(manifestPath)
    error('simtest:PackagedTestManagerManifestMissing', ...
        'Pipeline manifest is missing: %s', manifestPath);
end

manifest = jsondecode(fileread(manifestPath));
if ~isfield(manifest, 'Targets') || isempty(manifest.Targets)
    error('simtest:PackagedTestManagerTargetsMissing', ...
        'Pipeline manifest has no packaged targets: %s', manifestPath);
end
targets = manifest.Targets;

for k = 1:numel(targets)
    modelFile = char(string(targets(k).PackagedStandaloneModel));
    if ~isfile(modelFile)
        error('simtest:PackagedTestManagerModelMissing', ...
            'Standalone model is missing for target %d: %s', k, modelFile);
    end
    addpath(fileparts(modelFile));
    [~, modelName] = fileparts(modelFile);
    if bdIsLoaded(modelName)
        loadedFile = char(string(get_param(modelName, 'FileName')));
        expectedFile = char(java.io.File(modelFile).getCanonicalPath());
        actualFile = char(java.io.File(loadedFile).getCanonicalPath());
        if ispc
            sameModel = strcmpi(expectedFile, actualFile);
        else
            sameModel = strcmp(expectedFile, actualFile);
        end
        if ~sameModel
            error('simtest:PackagedTestManagerModelIsolationFailed', ...
                ['A different model is already loaded for %s. ' ...
                 'Expected=%s | Actual=%s'], ...
                modelName, expectedFile, actualFile);
        end
    else
        load_system(modelFile);
    end
end

testFiles = dir(fullfile(launcherDirectory, '*.mldatx'));
if numel(testFiles) ~= 1
    error('simtest:PackagedTestManagerFileAmbiguous', ...
        'Expected exactly one MLDATX file in %s, found %d.', ...
        launcherDirectory, numel(testFiles));
end
testFilePath = fullfile(testFiles(1).folder, testFiles(1).name);
testFile = sltest.testmanager.load(testFilePath);
testCases = getAllTestCases(testFile);

for k = 1:numel(targets)
    testCaseName = string(targets(k).TestCaseName);
    matches = find(string({testCases.Name}) == testCaseName);
    if numel(matches) ~= 1
        error('simtest:PackagedTestManagerCaseMappingFailed', ...
            'Expected one Test Case named %s, found %d.', ...
            char(testCaseName), numel(matches));
    end
    filterFile = char(string(targets(k).PackagedCVF));
    if ~isfile(filterFile)
        error('simtest:PackagedTestManagerFilterMissing', ...
            'Packaged CVF is missing for %s: %s', ...
            char(testCaseName), filterFile);
    end
    coverage = getCoverageSettings(testCases(matches));
    coverage.CoverageFilterFilename = filterFile;
    actual = string(coverage.CoverageFilterFilename);
    if ~any(strcmpi(actual, string(filterFile)))
        error('simtest:PackagedTestManagerFilterReadbackFailed', ...
            'Coverage filter readback failed for %s.', char(testCaseName));
    end
end

sltest.testmanager.view;
fprintf(['Standalone Test Manager loaded | TestFile=%s | ' ...
    'Models=%d | CVFs=%d\n'], testFilePath, numel(targets), numel(targets));
