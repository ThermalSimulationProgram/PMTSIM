function [Temperature] = computeTemp(TM, tslp, tact, Timp, isAct, isPeriodic)

Temperature = zeros(1, TM.n);

NonSkipAll = all( isAct == false);
for i = 1 : TM.n
    id_target = TM.coreIdx(i);
        if ~isAct(id_target) && ~NonSkipAll
            continue;
        end

    % the target node itself, and the four nodes bedides it, if exist, are
    % the nodes having strong influence to target node.
    if ~isempty(TM.Nodes)
    strongInfluence = [TM.Nodes(id_target).neighbs, id_target];
    else
        strongInfluence = 0;
    end
    strongTimps = PeriodSample(5, 1); % at most five strong nodes
    weakInfluence = 0;
    k = 1;
    
    for j = 1 : TM.n

        id_heatsource = TM.coreIdx(j);
        if ~isAct(id_heatsource)
            weakInfluence = weakInfluence + TM.TimpCores2Cores(id_target, id_heatsource);
            continue;
        end
        if isAct(id_heatsource) && ~isPeriodic(id_heatsource)
            weakInfluence = weakInfluence + TM.TimpCores2Cores(id_target, id_heatsource)...
                * TM.ua(id_heatsource) / TM.ui(id_heatsource);
            continue;
        end
        
        [flag timps] = ImpMatFindImpulse(Timp, id_target, id_heatsource,...
            tslp(id_heatsource), tact(id_heatsource));
        
        if ~flag
            id_target
            id_heatsource
            tslp(id_heatsource)
            tact(id_heatsource)
            error('Object Timp is not complete for calculation');
        end
        if length(timps) > 1
            warning('duplicated toff and ton have been appended');
            timps = timps(1,1);
        end
        
        if any(id_heatsource == strongInfluence)           
            strongTimps(k, 1) =  timps;
            k = k + 1;
        else
            weakInfluence = weakInfluence + timps(1,1).vMax;
        end
    end
    
    [maxSource] = BrutallyFindTheMaxSumOfPeriodics( strongTimps, TM.p);
    

    Temperature(i) = maxSource + weakInfluence + TM.TimpSumNonCore2Cores(id_target);
end

