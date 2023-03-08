function dynamicData = prepareCandids(dynamicData, config)

acn = config.activeNum;

candidToffs     = cell(acn, 1);
candidTons      = cell(acn, 1);
candidTslps     = cell(acn, 1);
candidTacts     = cell(acn, 1);

feasibleRegion  = dynamicData.feasibleRegion;
pToffTon        = dynamicData.pToffTon;
K               = dynamicData.K;
limit           = zeros(1, acn);
rho             = dynamicData.rho;
for i = 1 :acn
    %candidToffs{i}, vector of all the toffs in its feasible region of node coreIdx(i)
    % now, the unit of toff and ton is ms
    
    candidToffs{i} = feasibleRegion(i, 1) : config.step : feasibleRegion(i, 2);
    candidToffs{i}  =  candidToffs{i} ;
    limit(i) = size(candidToffs{i}, 2);
    candidTons{i} = K(i) / (1- rho) * candidToffs{i} + config.tswons(i) *(1- rho + K(i))/ (1 - rho);
    candidTslps{i} = candidToffs{i} -  config.tswoffs(i);
    candidTacts{i} = candidTons{i}  +  config.tswoffs(i);
    
    
    % trans to  resolution pToffTon,  unit ms
    
   % candidTons{i}   = round( candidTons{i} /  pToffTon ) * pToffTon;
   % candidTslps{i}  = round( candidTslps{i} / pToffTon ) * pToffTon;
   % candidTacts{i}  = round( candidTacts{i} /  pToffTon ) * pToffTon;
end

candids = struct('candidToffs',[], 'candidTons',[], ...
    'candidTslps', [], 'candidTacts',[]);
candids.candidToffs = candidToffs;
candids.candidTons  = candidTons;
candids.candidTslps = candidTslps;
candids.candidTacts = candidTacts;

dynamicData.candids = candids;
dynamicData.limit   = limit;



end