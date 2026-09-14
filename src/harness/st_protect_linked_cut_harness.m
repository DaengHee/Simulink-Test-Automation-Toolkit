function changed = st_protect_linked_cut_harness( ...
        cutPath, harnessName, cfg)
%ST_PROTECT_LINKED_CUT_HARNESS Prevent close-time CUT push to a library link.

changed = false;
cutPath = char(string(cutPath));
harnessName = char(string(harnessName));
linkState = st_cut_library_link_state(cutPath);
if ~linkState.IsLinked
    return;
end

items = sltest.harness.find( ...
    cutPath, 'SearchDepth', 0, 'Name', harnessName);
if isempty(items)
    return;
end
if numel(items) ~= 1
    error('simtest:HarnessLinkProtectionMappingFailed', ...
        'Expected one Harness for linked CUT %s, found %d: %s', ...
        cutPath, numel(items), harnessName);
end
if bdIsLoaded(harnessName)
    error('simtest:HarnessLinkProtectionRequiresClosedHarness', ...
        ['Close the Harness before library-link protection is applied: ' ...
         '%s'], harnessName);
end

modeValue = items(1).synchronizationMode;
mode = char(string(modeValue));
if is_sync_on_open(modeValue)
    st_assert_cut_library_link_unchanged( ...
        linkState, cutPath, 'Harness synchronization readback');
    return;
end

st_log(cfg, 'WARN', ...
    ['Library-linked CUT detected; changing Harness synchronization to ' ...
     'SyncOnOpen to prevent close-time push | CUT=%s | Harness=%s | ' ...
     'Previous=%s'], ...
    cutPath, harnessName, mode);
st_log(cfg, 'DEBUG', ...
    'Harness synchronization update start | CUT=%s | Harness=%s', ...
    cutPath, harnessName);
sltest.harness.set( ...
    cutPath, harnessName, 'SynchronizationMode', 'SyncOnOpen');
st_log(cfg, 'DEBUG', ...
    'Harness synchronization update end | CUT=%s | Harness=%s', ...
    cutPath, harnessName);

readback = sltest.harness.find( ...
    cutPath, 'SearchDepth', 0, 'Name', harnessName);
if numel(readback) ~= 1 || ...
        ~is_sync_on_open(readback(1).synchronizationMode)
    error('simtest:HarnessLinkProtectionReadbackFailed', ...
        'Harness synchronization readback failed: %s / %s', ...
        cutPath, harnessName);
end
st_assert_cut_library_link_unchanged( ...
    linkState, cutPath, 'Harness synchronization update');
changed = true;
end


function tf = is_sync_on_open(value)
% R2025b can report SynchronizationMode as numeric enum value 1.

if isnumeric(value) || islogical(value)
    tf = isscalar(value) && isfinite(double(value)) && double(value) == 1;
    return;
end

try
    text = string(value);
    tf = isscalar(text) && strcmpi(strtrim(text), "SyncOnOpen");
catch
    tf = false;
end
end
