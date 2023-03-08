function state = getPipelineStateWithPrediction(obj)

state0 = getPipelineState(obj);
% if obj.currentTime < obj.deltaT
% 
%     state1 = state0;
% else
%     tons = obj.tons + obj.tswons;
%     toffs = obj.toffs - obj.tswons;
% 
%     startTime = obj.currentTime;
%     endTime = round( (startTime + obj.adaptPeriod)/obj.deltaT)*obj.deltaT;
% 
%     [obj, ~] = dynamicTemRevSingleCoreVersion(obj, startTime, endTime, tons, toffs);
% 
%     obj.currentTime = endTime;
% 
%     state1 = getPipelineState(obj);
% 
% end
% 
% 
% state = [state0; state1];

state = state0;
end