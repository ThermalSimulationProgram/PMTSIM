function obj = fetchEventArriveInfo(obj)

EventId = obj.currentEventId;
%% new event arrives
obj.currentEvent = obj.inPort(EventId);
obj.currentTime = obj.currentEvent.arrivalTime;
% stored in the FIFO of first stage
obj.coreArray(1).inputFifo.nextEventInTime = obj.currentEvent.arrivalTime;
% get next event arrive time
if EventId < totalEvent
    obj.nextEventArriveTime = obj.inPort(EventId + 1).arrivalTime;
else % for the last event, we set as its deadline
    obj.nextEventArriveTime = obj.currentEvent.deadline;
end


end