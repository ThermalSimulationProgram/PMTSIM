function [NextObs,Reward,IsDone,LoggedSignals] = processorThermalStep(Action, LoggedSignals)
% Custom step function to construct cart-pole environmeTnt for the function
% name case.
%
% This function applies the given action to the environment and evaluates
% the system dynamics for one simulation step.

% Define the environment constants.
obj = LoggedSignals.obj;
temperatureConstraint = obj.temperatureConstraint;
rewardForPerformance = 2;
PenaltyForViolating = -100;

numCores = obj.nstage;
tons = Action(1:numCores, 1);
toffs = Action(numCores+1:numCores*2, 1);
tswons = obj.tswons;
obj.tons = tons;
obj.toffs = toffs;


obj.adaptcounter = obj.adaptcounter + 1;

% for i = 1 : obj.nstage
%     core = obj.coreArray(i);
%     core = getPTMcTrace(core, setlength, tons(i), toffs(i));
%     obj.coreArray(i) = core;
% end

obj.adaptTime = round( (obj.adaptTime + obj.adaptPeriod)/obj.deltaT)*obj.deltaT;

startTime = obj.currentTime;
endTime = obj.adaptTime;

[obj, ~] = dynamicTemRevSingleCoreVersion(obj, startTime, endTime, tons+tswons, toffs-tswons);

obj.currentTime = endTime;

LoggedSignals.State = getPipelineStateWithPrediction(obj);


% Transform state to observation.
NextObs = LoggedSignals.State;

% Check temperature constraint.
peakTemp = max(NextObs(1:numCores,1));
isViolated = peakTemp > temperatureConstraint;

IsDone = 0;

% time_coef = min(1, max(0.05, obj.currentTime / obj.rewardTime));
offset = 5;
borderLine = temperatureConstraint - offset;
diff2border = borderLine - peakTemp;
% isViolated = abs(diff2border) > 5;
% Get reward.
% if ~isViolated
%     Reward =  mean( (tons-tswons)./(tons+toffs) ) - 0.3*offsetBorderLine^2 -...
%         0.5 * (min(offsetBorderLine, 0))^2 + 25*Ts/Tf  - 0.1*var(NextObs);
% else
%     obj.violatedCounter = obj.violatedCounter + 1;
% end
if isViolated
    obj.violatedCounter = obj.violatedCounter + 1;
    IsDone = 1;
end
    %     r1 =  sum( (tons-tswons)./(tons+toffs) );
    %     r2 = - 0.03*abs(offsetBorderLine);
    %     r3 = - 0.5 * abs(min(offsetBorderLine, 0));
    %     r4 = 100*Ts/Tf;
    %     r5 = - 0.1*var(NextObs);
    %     r6 = isViolated*PenaltyForViolating*exp(-3/obj.violatedCounter);
    %     Reward = r1  + r4 ;
    %     Reward = 2;

%     max_r1 = 15;
%     min_r1 = -15;
%     mid_r1 = 1.5;
%     
%     b0 = max_r1;
%     a0 = (mid_r1 - b0)/(offset^2);
% 
%     max_diff_border = 70;
%     a1 = (mid_r1 - min_r1)/(offset - max_diff_border);
%     b1 = mid_r1 - a1*offset;
%     if abs(diff2border) <= 5
%         r1 = a0 * diff2border^2 + b0; %min:1.5, max:5
%     else
%         r1 = a1 * diff2border + b1;
%     end
x0 = 330;
x = (peakTemp-x0)/(380-x0);
if x < 0
    x = 0;
end
    r1  = 1.1*(x)^2;
    r4 = 2 * sum((tons-tswons)./(tons+toffs)) ; 
    

    Reward =  r1+r4 + PenaltyForViolating*isViolated;






LoggedSignals.obj = obj;

end