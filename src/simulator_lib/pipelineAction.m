function stage = pipelineAction(stage, nextAction, currentEvent)
currentTime =   stage.currentTime ;
if strcmp( nextAction.type, 'adapt')
    stage = pipelineAdaption(stage);
else
    actId = nextAction.id;
    [stage.coreArray(actId), finishEvent] = coreAction(stage.coreArray(actId),...
        currentTime, nextAction.type, currentEvent);
    
    % if an event is finished, pass it to next stage or outPort
    if strcmp(nextAction.type, 'finish')
        if nextAction.id ~= stage.nstage
            nextFifo = stage.coreArray(nextAction.id+1).inputFifo;
            nextFifo = enqueue(nextFifo, finishEvent);
            stage.coreArray(nextAction.id+1).inputFifo = nextFifo;
        else
            nextFifo = stage.outPort;
            nextFifo = enqueue(nextFifo, finishEvent);
            stage.outPort = nextFifo;
        end
    end
    % the stage should not know when the next event comes
    if nextAction.id == 1 && strcmp(nextAction.type, 'arrive')
        stage.coreArray(1).inputFifo.nextEventInTime = inf;
    end
    
end


end