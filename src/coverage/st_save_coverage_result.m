function st_save_coverage_result(path, objects, cfg)
%ST_SAVE_COVERAGE_RESULT Save coverage objects to a .cvt file via cvsave.
%
% cvsave embeds each object's source model info and fails with
% cvi.ReportUtils.checkModelLoaded:ModelNotOpen unless that model is
% still open, so this must be called before the model is closed.

[folder, name] = fileparts(path);
base = fullfile(folder, name);
arguments = [{base}; objects(:)];
writableCleanup = st_enter_writable_coverage_directory(cfg, 'CVSAVE');
cvsave(arguments{:});
clear writableCleanup;
if ~isfile(path)
    error('simtest:StandaloneCoverageResultSaveMissing', ...
        'cvsave did not create the expected file: %s', path);
end
end
