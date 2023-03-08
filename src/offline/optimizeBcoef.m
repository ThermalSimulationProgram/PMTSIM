function [optbcoef, peakTs, objs] = optimizeBcoef(config, range)

candids = range(1) : 0.01 : range(2);

bestT = inf;
bestbc = 0;
peakTs = [];
objs = [];
for bc = candids
    bc
    config.bcoef = bc;
    result = runApproaches(config, [1,0,0]);
    peakT = result.aptm.peakT;
    peakTs = [peakTs, peakT];
    if peakT < bestT
        bestT = peakT;
        bestbc = bc;
    end
   % save('optimizaBcoef2', 'bc', 'peakTs');
end
optbcoef = bestbc;



end
