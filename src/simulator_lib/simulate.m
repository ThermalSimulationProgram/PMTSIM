function [obj] = simulate(obj)
%simulate(obj) simulates the Pipeline object obj
% Name: simulate.m
%
%   simulation length: this simulation will not stop until all the events
%   in the pipeline's inPort are handled.
%   simulation results: The finish time of all events;
%                       The state trace of all cores;
%                       The temperature evolution curves for all cores;
%                       The time trace of the obj
%   Note that some dynamic filed of obj will be reset before simulation.
%
%   Author: Long
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the number of events will be simulated
totalEvent = numel(obj.inPort);

simTem = ~isempty(obj.TM);

for EventId = 1 : totalEvent
    
    
    %% new event arrives
    currentEvent = obj.inPort(EventId);
    currentTime = currentEvent.arrivalTime;
    % stored in the FIFO of first stage
    obj.coreArray(1).inputFifo.nextEventInTime = currentTime;
    % get next event arrive time
    if EventId < totalEvent
        nextEventArriveTime = obj.inPort(EventId + 1).arrivalTime;
    else % for the last event, we set as its deadline
        nextEventArriveTime = currentEvent.deadline;
    end
    
    
    while true
        %% find next action and simulate system till that time
        % get the action the system going to take
        [nextAction] = getNextAction(obj);
        
        if nextAction.time >= 3300 && strcmp(nextAction.type, 'adapt')
            ss=1;
        end
        
        % The nextAction needs revising, to consider next event arrival
        if round(nextAction.time/obj.deltaT) > round(nextEventArriveTime/obj.deltaT)
            scenario = 1;  % an event arrives before the action
            nextAction.type = 'arrive';
            nextAction.id = 1;
            runEndTime = nextEventArriveTime;
        else
            scenario = 2;  % the action happens before next event
            runEndTime = nextAction.time;
        end
        if currentTime > 1326
            ss=1;
        end
        
        % check if the obj should be simulated to next time instance
        if round(runEndTime/obj.deltaT) >= round( currentTime/obj.deltaT) + 1
            for i = 1 : obj.nstage
                % run the cores to action time
                obj.coreArray(i).currentTime = currentTime;
                [obj.coreArray(i), log] = temperalSimKernel(obj.coreArray(i), ...
                    runEndTime);
                % The simulation termination event should be consist with
                % promised nextAction
                if i == nextAction.id
                    switch nextAction.type
                        case 'adapt'
                            if   log.stopId > 0
                                error('an action happens during the simulation');
                            end
                        case 'finish'
                            if   log.stopId ~= 1
                                error('an unexpected action happens during the simulation');
                            end
                        case 'load'
                            if   log.stopId ~= 2
                                error('an unexpected action happens during the simulation');
                            end
                        case 'arrive'
%                             if   log.stopId > 0
%                                 error('an action happens during the simulation');
%                             end
                    end
                else
                    simError = true;
                    % the event on this stage finishes at the same time
                    if log.stopId == 1 && abs( obj.coreArray(i).eventFinishTime -...
                                    runEndTime ) < obj.deltaT
                                simError = false;
                    end
                    % this stage load event at the same time
                    if log.stopId == 2 && abs( obj.coreArray(i).nextEventLoadTime -...
                                    runEndTime ) < obj.deltaT
                                simError = false;
                    end
                    if log.stopId == 0
                        simError = false;
                    end
                    if simError
                        error('an unexpected action happens during the simulation');
                    end

                end
            end
           
            if simTem
                 % calculate the temperature
                obj = dynamicTem(obj, currentTime);
            end
        end
        % if next event arrives, stop current loop
        if scenario == 1
            break;
        end
        currentTime = nextAction.time;
        %% take the action
        obj.currentTime = currentTime;
        obj = pipelineAction(obj, nextAction, currentEvent);
        
        
        %% update stage information
         
        for i = 1 : obj.nstage
            [obj.coreArray(i)] = updateInfo(obj.coreArray(i));
        end
        
        
        
        
    end
    
    
    
    
    
    
end

end
