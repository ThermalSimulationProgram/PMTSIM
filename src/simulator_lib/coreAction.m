function [obj, finishEvent] = coreAction(obj, globalTime, actionType, StageEvent)
obj.currentTime = globalTime;
finishEvent = [];
switch actionType
    
    case 'arrive'
        if obj.id == 1
            obj.inputFifo = enqueue(obj.inputFifo, StageEvent);
        end
        
    case 'load'
        if ~isempty(obj.myevent)
            error('can not load because an event is still existing');
        end
        if obj.inputFifo.Q < 1
            error('no evnet to load');
        end
        if obj.state == obj.sleep 
            error('cannot load when sleeping');
        end
        if (obj.state == obj.swon ||  obj.state == obj.swoff) &&...
                obj.remainSwitch > 0
            error('cannot load during mode change');
        end
        
        
        obj.state = obj.active;
        newState = [obj.active, obj.currentTime, obj.currentTime];  	% active phase
        obj.stateTrace = [obj.stateTrace; newState ];
        [obj.inputFifo, obj.myevent] = fetch(obj.inputFifo);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        obj.myevent.curStage = obj.id;
        obj.myevent.executed = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        obj.eventTrace = [obj.eventTrace; obj.myevent.id, ...
            obj.myevent.wcetArray(obj.id)];
    case 'finish'
        if isempty(obj.myevent)
            error('No event to finish');
        end
        
        if getLoad(obj) >= obj.deltaT
            error('not finished');
        end
        finishEvent = obj.myevent;
        if obj.myevent.nstage == obj.id %  end stage
            if round(obj.myevent.finishTime,8) > round(obj.myevent.deadline,8)
%                 disp('a deadline miss happened');
            end
            if obj.myevent.id >= obj.displaytick
                disp([num2str(obj.myevent.id), 'th event finishes at ',...
                    num2str(obj.myevent.finishTime), ' with deadline ',...
                    num2str(obj.myevent.deadline)]);
                obj.displaytick = obj.displaytick + obj.displayInterval;
            end
            
        end
        obj.myevent = [];
        obj.state = obj.idle;  %  set state to idle;
        newState = [obj.idle, obj.currentTime, obj.currentTime];  	% active phase
        obj.stateTrace = [obj.stateTrace; newState ];
        obj.eventFinishTime = inf;
end


end
