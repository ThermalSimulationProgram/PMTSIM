function [solution,Tpeak,exitflag,output] = PBOOSA(TM, config, dynamicData)
%% pre-processing
%[defaultToffs, ~]  = getPTMs(dynamicData.candids, ones(1, config.activeNum));
 [~, solutionfbpt] = findTheOptSolutionByGradient2(TM, config, dynamicData);
 defaultToffs = shrinkVars(solutionfbpt(1,:), config.actcoreIdx);
lbToffs = dynamicData.feasibleRegion(:,1)';
ubToffs = dynamicData.feasibleRegion(:,2)';
SumBound = dynamicData.SumBound;
Timp    = dynamicData.Timp;        
K       = dynamicData.K;
numberOfVariables = numel(defaultToffs);
%% Start with the default options
options = saoptimset;
%% Modify options setting
%   TolFun               - Termination tolerance on function value
%                          [ positive scalar | {1e-6} ]
scalor = 0.001;
p = TM.p/scalor;

TolFun_Data = 1e-03;
DisplayInterval_Data = 10;
InitialTemperature = 100;
options = saoptimset(options,'TolFun', TolFun_Data);
options = saoptimset(options,'MaxFunEvals', 2500*numberOfVariables);
options = saoptimset(options,'Display', 'iter');
options = saoptimset(options,'DisplayInterval', DisplayInterval_Data);
options = saoptimset(options,'AnnealingFcn', @annealingCSA);
options = saoptimset(options,'InitialTemperature', InitialTemperature);

[bestToffs,Tpeak,exitflag,output] = ...
    simulannealbnd(@ObjectFun,defaultToffs,lbToffs,ubToffs,options);
bestTons = K ./ (1-K) .* bestToffs + config.tswons ./ (1-K);
solution = [bestToffs;bestTons];

    function T = ObjectFun(toffs)
        [tact, tslp]= prepareTacts(toffs, K, config);
        isFast = false; 
        [T, Timp, ~] = CalculatePeakTemperatureV2(isFast, TM, tslp, tact,Timp); 
    end
 


    function [newx] = annealingCSA(optimValues,problem)
        
        currentx = optimValues.x;
        
        nvar = numel(currentx);
        newx = currentx;
        changeId = randi([1,nvar]);
        newlb               = problem.lb;
        linearub            = problem.ub;
        linearub(changeId)  = SumBound - ( sum(currentx) - currentx(changeId) );
        newub = min(problem.ub, linearub);
        
        
        eta = optimValues.temperature(changeId) / InitialTemperature;
        
        randstep            = 2 * rand - 1;
        try
        newx(changeId)      = newx(changeId) + eta * (newub(changeId) - newlb(changeId)) * randstep;
        catch
            eta
            newub
            newlb
            randstep
            newx
        end
        
        newx = round(newx/p)*p;
        
        if ~problem.bounded
            return
        end
        
        xin = newx; % Get the shape of input
        newx = newx(:); % make a column vector
        lb = newlb;
        ub = newub;
        lbound = (newx < lb);
        ubound = (newx > ub);
        alpha = rand;
        % Project newx to the feasible region; get a random point as a convex
        % combination of proj(newx) and currentx (already feasible)
        if any(lbound) || any(ubound)
            projnewx = newx;
            projnewx(lbound) = lb(lbound);
            projnewx(ubound) = ub(ubound);
            newx = alpha*projnewx + (1-alpha)*optimValues.x(:);
            % Reshape back to xin
            newx = reshapeinput(xin,newx);
        else
            newx = xin;
        end
        
        
        
    end




end



% function H = getH(tslps)
%         H = abs( geth(tslps) );
%     end
% 
%     function h = geth(tslps)
%         g = sum(tslps) - SumBound; %% constraint g <= 0
%         h = max(g, 0);
%     end
