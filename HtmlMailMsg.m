function MailMsg = HtmlMailMsg(profStatus,addTxtMsg)
if profStatus
    profileInfo = profile('info');
    MailMsg = Profview(profileInfo,addTxtMsg);
else
    MailMsg = {};
    MailMsg{1} = makeheadhtml;
    MailMsg{end+1} = '<body>';
    MailMsg{end+1} = ['<h1>', '您的程序已运行结束!', '</h1>'];
    MailMsg{end+1} = '<div style="background-color: #FFE4B0">';
    MailMsg{end+1} = '<h3>推荐在您的m文件最前添加如下代码以便分析运行性能：</h3><p> profile on;</p>';
    MailMsg{end+1} = '</div>';
    MsgBody = strcat('<p>',addTxtMsg,'</p>');
    MailMsg{end+1} = [MsgBody{:}];
    MailMsg{end+1} = '</body>';
    MailMsg{end+1} = '</html>';
    MailMsg = [MailMsg{:}];
end

function htmlOut = makeheadhtml
% MAKEHEADHTML  Add a head for HTML report file.
%   Use locale to determine the appropriate charset encoding.
%
%   Note: <html> and <head> tags have been opened but not closed. 
%   Be sure to close them in your HTML file.

%   Copyright 1984-2014 MathWorks, Inc.

h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

% Use charset=UTF-8, g589137 g589371
encoding = 'UTF-8';
h3 = sprintf('<head><meta http-equiv="Content-Type" content="text/html; charset=%s" />',encoding);

% Add cascading style sheet link
cssfile = 'https://www.noahbear.top/sites/matlab-report-styles.css';
h4 = sprintf('<link rel="stylesheet" href="%s" type="text/css" />',cssfile);

h5 = ['<title>', '您的程序已运行结束!', '</title></head>'];

htmlOut = [h1 h2 h3 h4 h5];

function htmlOut = Profview(profileInfo,addTxtMsg)
import com.mathworks.mde.profiler.Profiler;
Profiler.stop;

% pixel gif location
pixelPath = 'https://www.noahbear.top/sites/';
cyanPixelGif = [pixelPath 'one-pixel-cyan.gif'];
bluePixelGif = [pixelPath 'one-pixel.gif'];

% Read in preferences
sortMode = getpref('profiler','sortMode','totaltime');

allTimes = [profileInfo.FunctionTable.TotalTime];
maxTime = max(allTimes);

% check if there is any memory data in the profile info
hasMem = hasMemoryData(profileInfo);

% check if there is any hardware performance counter data in the profile info
hwFields = getHwFields(profileInfo);
hasHw = (~isempty(hwFields));

% Calculate self time and optionally self memory and self performance counter list
allSelfTimes = zeros(size(allTimes));
if hasMem
    allSelfMem = zeros(size(allTimes));
end
for i = 1:length(profileInfo.FunctionTable)
    allSelfTimes(i) = profileInfo.FunctionTable(i).TotalTime - ...
        sum([profileInfo.FunctionTable(i).Children.TotalTime]);
    if hasMem
        netMem = (profileInfo.FunctionTable(i).TotalMemAllocated - ...
            profileInfo.FunctionTable(i).TotalMemFreed);
        childNetMem = (sum([profileInfo.FunctionTable(i).Children.TotalMemAllocated]) - ...
            sum([profileInfo.FunctionTable(i).Children.TotalMemFreed]));
        allSelfMem(i) = netMem - childNetMem;
    end
    for j=1:length(hwFields)
        child_hw = sum([profileInfo.FunctionTable(i).Children.(hwFields{j})]);
        allHw{j}(i) = profileInfo.FunctionTable(i).(hwFields{j});
        allSelfHw{j}(i) = allHw{j}(i) - child_hw;
    end
end

totalTimeFontWeight = 'normal';
selfTimeFontWeight = 'normal';
alphaFontWeight = 'normal';
numCallsFontWeight = 'normal';
allocMemFontWeight = 'normal';
freeMemFontWeight = 'normal';
peakMemFontWeight = 'normal';
selfMemFontWeight = 'normal';

% hwFontWeight(i) is for total data
% hwFontWeight(i+length(hwFields)) is for self data
for j=1:2*length(hwFields)
    hwFontWeight{j} = 'normal';
end

% if the sort mode is set to a memory field but we don't have
% any memory data, we need to switch back to time.
if ~hasMem && (strcmp(sortMode, 'allocmem') || ...
        strcmp(sortMode, 'freedmem') || ...
        strcmp(sortMode, 'peakmem')  || ...
        strcmp(sortMode, 'selfmem'))
    sortMode = 'totaltime';
end

badSortMode = false;
if strcmp(sortMode,'totaltime')
    totalTimeFontWeight = 'bold';
    [~,sortIndex] = sort(allTimes,'descend');
elseif strcmp(sortMode,'selftime')
    selfTimeFontWeight = 'bold';
    [~,sortIndex] = sort(allSelfTimes,'descend');
elseif strcmp(sortMode,'alpha')
    alphaFontWeight = 'bold';
    allFunctionNames = {profileInfo.FunctionTable.FunctionName};
    [~,sortIndex] = sort(allFunctionNames);
elseif strcmp(sortMode,'numcalls')
    numCallsFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.NumCalls],'descend');
elseif strcmp(sortMode,'allocmem')
    allocMemFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.TotalMemAllocated],'descend');
elseif strcmp(sortMode,'freedmem')
    freeMemFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.TotalMemFreed],'descend');
elseif strcmp(sortMode,'peakmem')
    peakMemFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.PeakMem],'descend');
elseif strcmp(sortMode,'selfmem')
    selfMemFontWeight = 'bold';
    [~,sortIndex] = sort(allSelfMem,'descend');
elseif strncmp('total_',sortMode,6)
    % check if sort mode is for hardware performance counter
    match = strcmpi(sortMode(7:end), hwFields);
    if any(match)
        idx = 1:length(hwFields);
        j = idx(match);
        hwFontWeight{j} = 'bold';
        [~,sortIndex] = sort(allHw{j},'descend');
    else
        badSortMode = true;
    end
elseif strncmp('self_',sortMode,5)
    % check if sort mode is for hardware performance counter
    match = strcmpi(sortMode(6:end),hwFields);
    if any(match)
        idx = 1:length(hwFields);
        j = idx(match);
        hwFontWeight{j+length(hwFields)} = 'bold';
        [~,sortIndex] = sort(allSelfHw{j},'descend');
    else
        badSortMode = true;
    end
end

if badSortMode
    error(message('MATLAB:profiler:BadSortMode', sortMode));
end

s = {}; %#ok<*AGROW>
s{1} = makeheadhtml;
s{end+1} = '<body>';
s{end+1} = ['<h1>', '您的程序已运行结束!', '</h1>'];
MsgBody = strcat('<p>',addTxtMsg,'</p>');
s{end+1} = [MsgBody{:}];

% Summary info

status = profile('status');
s{end+1} = ['<span style="font-size: 14pt; background: #FFE4B0">', getString(message('MATLAB:profiler:ProfileSummaryName')), '</span><br/>'];
s{end+1} = ['<i>', getString(message('MATLAB:profiler:GeneratedUsing', datestr(now), status.Timer)), '</i><br/>'];

if isempty(profileInfo.FunctionTable)
    s{end+1} = ['<p><span style="color:#F00">', getString(message('MATLAB:profiler:NoProfileInfo')), '</span><br/>'];
    s{end+1} = [getString(message('MATLAB:profiler:NoteAboutBuiltins')), '<p>'];
end

s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
s{end+1} = '<tr>';
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
%s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''alpha'');profview(0)">';
s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:FunctionNameTableElement')) , '</span></td>'],alphaFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
%s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''numcalls'');profview(0)">';
s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:CallsTableElement')), '</span></td>'],numCallsFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
%s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''totaltime'');profview(0)">';
s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:TotalTimeTableElement')), '</span></td>'],totalTimeFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
%s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''selftime'');profview(0)">';
s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:SelfTimeTableElement')), '</span>*</td>'],selfTimeFontWeight);

% Add column headings for memory data.
if hasMem
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
    %s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''allocmem'');profview(0)">';
    s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:AllocatedMemoryTableElement')), '</span></td>'],allocMemFontWeight);
    
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
    %s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''freedmem'');profview(0)">';
    s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:FreedMemoryTableElement')), '</span></td>'],freeMemFontWeight);
    
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
    %s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''selfmem'');profview(0)">';
    s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:SelfMemoryTableElement')), '</span></td>'],selfMemFontWeight);
    
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
    %s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''peakmem'');profview(0)">';
    s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:PeakMemoryTableElement')), '</span></td>'],peakMemFontWeight);
end

% Add column headings for hardware performance counter data.
for j=1:length(hwFields)
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
    s{end+1} = sprintf('<a href="matlab: setpref(''profiler'',''sortMode'',''total_%s'');profview(0)">', lower(hwFields{j}));
    s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:TotalTableElement',  hwFields{j}(4:end))), '</span></a></td>'], hwFontWeight{j});
    
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
    s{end+1} = sprintf('<a href="matlab: setpref(''profiler'',''sortMode'',''self_%s'');profview(0)">', lower(hwFields{j}));
    s{end+1} = sprintf(['<span style="font-weight:%s">', getString(message('MATLAB:profiler:SelfTableElement', hwFields{j}(4:end))) ,'</span></a></td>'], hwFontWeight{j+length(hwFields)});
end

s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">', getString(message('MATLAB:profiler:TotalTimePlotTableElement')), '<br/>'];
s{end+1} = [getString(message('MATLAB:profiler:DarkBandSelfTime')), '</td>'];
s{end+1} = '</tr>';

for i = 1:length(profileInfo.FunctionTable),
    n = sortIndex(i);
    
    name = profileInfo.FunctionTable(n).FunctionName;
    
    s{end+1} = '<tr>';
    
    % Truncate the name if it gets too long
    displayFunctionName = truncateDisplayName(name, 40);
    
    s{end+1} = sprintf('<td class="td-linebottomrt">%s', ...
        displayFunctionName);
    
    if isempty(regexp(profileInfo.FunctionTable(n).Type,'^M-','once'))
        s{end+1} = sprintf(' (%s)</td>', ...
            typeToDisplayValue(profileInfo.FunctionTable(n).Type));
    else
        s{end+1} = '</td>';
    end
    
    s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
        profileInfo.FunctionTable(n).NumCalls);
    
    
    % Don't display the time if it's zero
    if profileInfo.FunctionTable(n).TotalTime > 0,
        s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>', ...
            profileInfo.FunctionTable(n).TotalTime);
    else
        s{end+1} = '<td class="td-linebottomrt">0 s</td>';
    end
    
    if maxTime > 0,
        timeRatio = profileInfo.FunctionTable(n).TotalTime/maxTime;
        selfTime = profileInfo.FunctionTable(n).TotalTime - sum([profileInfo.FunctionTable(n).Children.TotalTime]);
        selfTimeRatio = selfTime/maxTime;
    else
        timeRatio = 0;
        selfTime = 0;
        selfTimeRatio = 0;
    end
    
    s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>',selfTime);
    
    % Add column data for memory
    if hasMem
        % display alloc, freed, self and peak mem on summary page
        totalAlloc = profileInfo.FunctionTable(n).TotalMemAllocated;
        totalFreed = profileInfo.FunctionTable(n).TotalMemFreed;
        netMem = totalAlloc - totalFreed;
        childAlloc = sum([profileInfo.FunctionTable(n).Children.TotalMemAllocated]);
        childFreed = sum([profileInfo.FunctionTable(n).Children.TotalMemFreed]);
        childMem = childAlloc - childFreed;
        selfMem = netMem - childMem;
        peakMem = profileInfo.FunctionTable(n).PeakMem;
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalAlloc));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalFreed));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,selfMem));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,peakMem));
    end
    
    % Add column data for hardware performance counters
    for j=1:length(hwFields)
        total = profileInfo.FunctionTable(n).(hwFields{j});
        child_total = sum([profileInfo.FunctionTable(n).Children.(hwFields{j})]);
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(3,total));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(3,total-child_total));
    end
    
    s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10><img src="%s" width=%d height=10></td>', ...
        bluePixelGif, round(100*selfTimeRatio), ...
        cyanPixelGif, round(100*(timeRatio-selfTimeRatio)));
    
    s{end+1} = '</tr>';
end
s{end+1} = '</table>';

if profileInfo.Overhead==0
    s{end+1} = sprintf(['<p><a name="selftimedef"></a>', getString(message('MATLAB:profiler:SelfTime1st')) ' ']);
else
    s{end+1} = sprintf(['<p><a name="selftimedef"></a>', getString(message('MATLAB:profiler:SelfTime2nd', profileInfo.Overhead))]);
end
s{end+1} = '</body>';
s{end+1} = '</html>';

htmlOut = [s{:}];

function escapedString = escapeHtml(originalString)
%ESCAPEHTML Escapes the characters in a String using HTML entities
 
escapedString = char(org.apache.commons.lang.StringEscapeUtils.escapeHtml(originalString));

% --------------------------------------------------
function shortFileName = truncateDisplayName(longFileName,maxNameLen)
%TRUNCATEDISPLAYNAME  Truncate the name if it gets too long

shortFileName = escapeHtml(longFileName);
if length(longFileName) > maxNameLen,
    shortFileName = char(com.mathworks.util.FileUtils.truncatePathname( ...
        shortFileName, maxNameLen));
end

% --------------------------------------------------
function b = hasMemoryData(s)
% Does this profiler data structure have memory profiling information in it?
b = (isfield(s, 'PeakMem') || ...
    (isfield(s, 'FunctionTable') && isfield(s.FunctionTable, 'PeakMem')));

% --------------------------------------------------
function f = getHwFields(s)
% Get the field names for any hardware performance counter data
if isfield(s, 'FunctionTable')
    names = fieldnames(s.FunctionTable);
else
    names = fieldnames(s);
end
f = names(strncmp('HW',names,2));

% --------------------------------------------------
function s = formatData(key_data_field, num)
% Format a number as seconds or bytes depending on the
% value of key_data_field (1 = time, 2 = memory, 3 = other)
switch(key_data_field)
    case 1
        if num > 0
            s = sprintf('%4.3f s', num);
        else
            s = '0 s';
        end
    case 2
        num = num ./ 1024;
        s = sprintf('%4.2f Kb', num);
    case 3
        s = num2str(num);
end

% --------------------------------------------------
function n = busyLineSortKeyStr2Num(str)
% Convert between string names and profile data sort types
% (see key_data_field)
if strcmp(str, 'time')
    n = 1;
    return;
elseif strcmp(str, 'allocated memory')
    n = 2;
    return;
elseif strcmp(str, 'freed memory')
    n = 3;
    return;
elseif strcmp(str, 'peak memory')
    n = 4;
    return;
else
    hw_events = callstats('hw_events');
    match = strcmpi(['hw_' str],hw_events);
    if any(match)
        idx = 1:length(hw_events);
        if callstats('memory') > 1
            n = idx(match) + 4;
        else
            n = idx(match) + 1;
        end
        return;
    end
end

error(message('MATLAB:profiler:UnknownSortKind', str));

function str = typeToDisplayValue(type)
%convert function info table TYPE strings to display strings
switch type
    case 'M-function'
        str = getString(message('MATLAB:profiler:Function'));
    case 'M-subfunction'
        str = getString(message('MATLAB:profiler:Subfunction'));
    case 'M-anonymous-function'
        str = getString(message('MATLAB:profiler:AnonymousFunctionShort'));
    case 'M-nested-function'
        str = getString(message('MATLAB:profiler:NestedFunction'));
    case 'M-method'
        str = getString(message('MATLAB:profiler:Method'));
    case 'M-script'
        str = getString(message('MATLAB:profiler:Script'));
    case 'MEX-function',
        str = getString(message('MATLAB:profiler:MEXfile'));
    case 'Builtin-function'
        str = getString(message('MATLAB:profiler:BuiltinFunction'));
    case 'Java-method'
        str = getString(message('MATLAB:profiler:JavaMethod'));
    case 'constructor-overhead'
        str = getString(message('MATLAB:profiler:ConstructorOverhead'));
    case 'MDL-function'
        str = getString(message('MATLAB:profiler:SimulinkModelFunction'));
    case 'Root'
        str = getString(message('MATLAB:profiler:Root'));
    otherwise
        str = type;
end