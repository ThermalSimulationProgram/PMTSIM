function c = changeStageNumConfig(c, newstagenum, deadlinefactor)
if nargin < 2
    deadlinefactor = [];
end

if isempty(deadlinefactor)
    deadlinefactor = c.deadlinefactor;
end
% update config
c.nstage = newstagenum;
c.exefactor = c.exefactor(1) * ones(1, newstagenum);
c.deadlinefactor = deadlinefactor;


% modify wcets
c.activeCoreIdx = chooseActCores(c.flp, newstagenum);
c.wcets = c.allwcets(c.activeCoreIdx);
c.activeCoreIdx = c.activeCoreIdx;

c = newInputConfig(c);

% modify the offline data
c.offlineData.mtdata = c.allofflineData.mtdata(c.activeCoreIdx);
slopedata = c.allofflineData.slopedata;
for i = 1 : numel(slopedata)
    slopedata{i} = slopedata{i}(c.activeCoreIdx);
end
c.offlineData.slopedata = slopedata;

end
