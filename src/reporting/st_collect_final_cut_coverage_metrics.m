function metrics = st_collect_final_cut_coverage_metrics( ...
        resultObj, target, varargin)
%ST_COLLECT_FINAL_CUT_COVERAGE_METRICS Return unambiguous CUT scalar metrics.
%
% The returned source remains PROVISIONAL until it is compared with the
% Details section of an R2025b Test Manager HTML report.

p = inputParser;
addParameter(p, 'LogConfig', [], @(x) isempty(x) || isstruct(x));
addParameter(p, 'CoverageObjects', {}, @(x) iscell(x));
parse(p, varargin{:});
cfg = p.Results.LogConfig;
timerValue = tic;
if ~isempty(cfg)
    st_log(cfg, 'INFO', ...
        'Final CUT coverage metric collection start');
end

if isstruct(target)
    target = struct2table(target, 'AsArray', true);
end
if ~istable(target) || height(target) ~= 1
    error('simtest:StandaloneMetricTargetInvalid', ...
        'target must describe exactly one CUT.');
end

rows = st_collect_coverage_summary( ...
    resultObj, target, 'FILTERED_FINAL', ...
    'IncludeTestDetails', false, 'MatchCoverageObjects', true, ...
    'CoverageObjects', p.Results.CoverageObjects);
metrics = struct( ...
    'Decision', empty_metric(), ...
    'Execution', empty_metric(), ...
    'Source', 'Result coverage API matched by StandaloneCUTPath', ...
    'SourceStatus', 'PROVISIONAL');
metrics.Decision = select_metric(rows, 'Decision');
metrics.Execution = select_metric(rows, 'Execution');
if strcmp(metrics.Decision.Status, 'AMBIGUOUS') || ...
        strcmp(metrics.Execution.Status, 'AMBIGUOUS')
    metrics.SourceStatus = 'AMBIGUOUS';
elseif ~strcmp(metrics.Decision.Status, 'OK') || ...
        ~strcmp(metrics.Execution.Status, 'OK')
    metrics.SourceStatus = 'INCOMPLETE';
end
if ~isempty(cfg)
    if any(strcmp(metrics.SourceStatus, {'AMBIGUOUS','INCOMPLETE'}))
        level = 'WARN';
    else
        level = 'INFO';
    end
    st_log(cfg, level, ...
        ['Final CUT coverage metric collection complete | ' ...
         'SourceStatus=%s | Decision=%s | Execution=%s | elapsed=%.3f sec'], ...
        metrics.SourceStatus, metrics.Decision.Status, ...
        metrics.Execution.Status, toc(timerValue));
end
end

function value = select_metric(rows, name)
matches = rows.Level == "CUT" & strcmpi(rows.Metric, name) & ...
    rows.Status == "OK";
indices = find(matches);
value = empty_metric();
if isempty(indices)
    value.Status = 'MISSING';
    value.Message = sprintf('%s coverage row is unavailable.', name);
    return;
end
if numel(indices) ~= 1
    value.Status = 'AMBIGUOUS';
    value.Message = sprintf('%s matched %d coverage rows.', ...
        name, numel(indices));
    return;
end
row = rows(indices,:);
value.Covered = double(row.Covered);
value.Total = double(row.Total);
[percentage, text] = st_coverage_percentage(row.Covered, row.Total);
value.Percentage = percentage;
value.PercentageText = char(text);
value.Status = 'OK';
value.Message = '';
end

function value = empty_metric()
value = struct('Covered', NaN, 'Total', NaN, 'Percentage', NaN, ...
    'PercentageText', 'N/A', 'Status', 'NOT_RUN', 'Message', '');
end
