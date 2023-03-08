function offlineData = startOfflineLearning(TM, tacts, maxtslp, step)

if nargin < 3
    maxtslp = [];
end
if nargin < 4
    step = [];
end

slopedata   = offlineLearning(TM);
coolingdata = offlineLearningMiniTact(TM, tacts, maxtslp, step);
offlineData = getOfflineData(slopedata, coolingdata);
end
