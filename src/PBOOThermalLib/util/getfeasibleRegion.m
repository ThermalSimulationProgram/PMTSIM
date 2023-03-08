function dynamicData = getfeasibleRegion(dynamicData, config, TM)

acn = config.activeNum;
feasibleRegion = zeros(acn, 2);
% feasibleRegion, (*,1) the lower bounds, (*,2) the upper bpounds

for i = 1 : acn
    if TM.isCore(config.actcoreIdx(i)) == 0
        error('coreIdx in config error');
    end
    feasibleRegion(i,1) = config.tswoffs(i) + dynamicData.pToffTon;
    feasibleRegion(i,2) = dynamicData.b - config.sumWcet - config.sumTswoff...
        + config.wcets(i) + config.tswoffs(i);  
    if feasibleRegion(i,2) < feasibleRegion(i,1)
        error('b too small');
    end
end
dynamicData.feasibleRegion = feasibleRegion;

end