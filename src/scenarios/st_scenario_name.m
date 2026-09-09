function name = st_scenario_name(cutName, index)
%ST_SCENARIO_NAME Return UT_REQ_{CUTName}_{three-digit index}.

if nargin < 2
    index = 1;
end

index = double(index);
if ~isscalar(index) || ~isfinite(index) || index < 1 || ...
        index > 999 || mod(index,1) ~= 0
    error('Scenario index must be an integer in the range 1..999.');
end

cutName = char(strtrim(string(cutName)));

% The generated scenario name becomes a real MATLAB variable name (Signal
% Editor Dataset variable, Assessment scenario, Test Manager Iteration), so
% CUTName characters that are valid in a Simulink block name but not in a
% MATLAB identifier (for example '/') must be sanitized here. The original
% CUTName/CUTPath used to resolve the actual block are never modified.
safeCutName = regexprep(cutName, '[^A-Za-z0-9_]', '_');

name = sprintf('UT_REQ_%s_%03d', safeCutName, index);

if ~isvarname(name)
    error('Scenario name is not a valid MATLAB variable name: %s', name);
end
end
