function Temperature = computeTempQuick(TM, tslp, tact, Timp, isAct, isPeriodic)

Temperature = zeros(1, TM.n);

for i = 1 : TM.n
    id_target = TM.coreIdx(i);
        if ~isAct(id_target)
            continue;
        end

    for j = 1 : TM.n
        id_heatsource = TM.coreIdx(j);
        if ~isAct(id_heatsource)
            Temperature(i) = Temperature(i) + TM.TimpCores2Cores(id_target, id_heatsource);
            continue;
        end
        if isAct(id_heatsource) && ~isPeriodic(id_heatsource)
            Temperature(i) = Temperature(i) + TM.TimpCores2Cores(id_target, id_heatsource)...
                * TM.ua(id_heatsource) / TM.ui(id_heatsource);
            continue;
        end
        
        [flag, timps] = ImpMatFindImpulse(Timp, id_target, id_heatsource,...
            tslp(id_heatsource), tact(id_heatsource));
        
        if ~flag
            id_target
            id_heatsource
            tslp(id_heatsource)
            tact(id_heatsource)
            error('Object Timp is not complete for calculation');
        end
        if length(timps) > 1
            error('duplicated toff and ton have been appended');
        end
            Temperature(i) = Temperature(i) + timps(1,1).vMax;
 
    end    
    Temperature(i) = Temperature(i) + TM.TimpSumNonCore2Cores(id_target);
end


end