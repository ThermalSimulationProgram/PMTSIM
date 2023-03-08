function [resultDataout] = mergerResultsfromdisk(activenumids, platform)

% init out
resultDataout = getresultData();
validateattributes(activenumids, {'double', 'single'}, ...
    {'vector', 'nonnegative', 'integer', '<=', 48, '>=',2});
% record current path for resuming after finished
cwpath = pwd;
% number of actived cores
n = numel(activenumids);

prefixname = {'resultObject_IntelSCC','ARM8cores' };
validScopesIntel     = {'i', 'I','intel','Intel','INTEL','IntelSCC','scc','SCC','INTELSCC'};
checkScopeIntel      = @(x) any( validatestring( x, validScopesIntel));
validScopesARM     = {'a', 'A','arm','ARM'};
checkScopeARM      = @(x) any( validatestring( x, validScopesARM));

if nargin < 2 
    platform = 'IntelSCC';
else 
    try checkScopeIntel(platform)
        platform = 'IntelSCC';
    catch MExc1
        try checkScopeARM(platform)
            platform = 'ARM';
        catch MExc2
            MExc2 = addCause(MExc2, MExc1);
            throw(MExc2);
        end
    end 
end


if strcmp(platform, 'IntelSCC')
    name = prefixname{1};
else if strcmp(platform, 'ARM')
        name = prefixname{2};
    end
end
for i = 1 : n
    loadname = strcat(name, num2str(activenumids(i))  , '.mat');
    option2 = pathoptiset(mfilename('fullpath'), 'o','d',loadname);
    [~, loadfile2] = getPath(option2);
    load(loadfile2);
    resultDataout = mergeResultData(resultDataout, resultData);
end

cd(cwpath)
end


