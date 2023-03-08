function obj = getInputs(obj, inputTrace)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GETINPUTS.m Prepares inputs configurated by inputTrace in the pipeline
% Inputs:       obj         -- the pipeline object
%               inputTrace  -- a structure containing all information of
%                               inputs
% Output:       obj         -- the pipeline object with inputs
% Call: obj = getInputs(obj, inputTrace);
% 
% version: 1.0, 27/12/2016 
% author: Long, chengl@in.tum.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


trace       = inputTrace.trace;
% arrival times and execution times of all input events
% trace here: trace(:, 1) the time points of event arrivals
%             trace(:, 2) the number of events arriving at corresponding
%             time
%             trace(:, 3) the absolute deadlines
%             trace(:, 4) real exe times of the events at first stage
%             trace(:, 5) real exe times of the events at second stage
%               ...
%             trace(:, n) real exe times of the events at final stage
% the stage number indicated by trace must equal the stage number in obj.


eventArray  = [];
% construct array of events
for i = 1 : size(trace, 1)
    eventArray = [eventArray, Event(i, obj.nstage, trace(i,4:end), trace(i,1),...
        trace(i,3), obj.deltaT)];
end
% insert event array in inPort
obj.inPort          = [obj.inPort, eventArray];

% online adaption related parameters
obj.WCETs           = inputTrace.wcets;
obj.buckets         = inputTrace.buckets;
obj.stepWidth       = inputTrace.stepWidth;
obj.upperBoundsI    = inputTrace.upperBoundsI;
obj.accuTrace       = inputTrace.accuTrace;
obj.trace           = trace;

end
