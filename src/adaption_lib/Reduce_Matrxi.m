function ASC = Reduce_Matrxi(activeStageIndex, na, sleepStageIndex, nsleepStage,...
    consistConstSet, nconsistConstSet, deadlineConstSet, ndeadlineConstSet)

while(~isempty(sleepStageIndex))
    
    Index                       = sleepStageIndex(1);
    sleepStageIndex( 2:end )    = sleepStageIndex(2:end)-1;
    
    fActiveIndex        = activeStageIndex > Index;
    activeStageIndex( fActiveIndex ) = activeStageIndex(...
        fActiveIndex ) - 1;
    sleepStageIndex             = sleepStageIndex(2:end);
    nsleepStage                 = nsleepStage - 1;
    
    
    indice2 = ndeadlineConstSet - Index + 1: ndeadlineConstSet;
    deadlineConstSet(indice2) = deadlineConstSet(indice2) - consistConstSet(1);
    
    
    
    if( ndeadlineConstSet > Index )
        diff = ndeadlineConstSet - Index;
        deadlineConstSet(diff) =  min( deadlineConstSet(diff), deadlineConstSet(diff+1) );
    end
    shiftIndex = ndeadlineConstSet - Index + 1 : (ndeadlineConstSet-1);
    deadlineConstSet(shiftIndex) = deadlineConstSet(shiftIndex + 1);
    
    
    ndeadlineConstSet 	= ndeadlineConstSet-1;
    deadlineConstSet  	= deadlineConstSet( 1: ndeadlineConstSet );
    consistConstSet   	= consistConstSet( 2:end );
    nconsistConstSet  	= nconsistConstSet - 1;
end

ASC = deadlineConstSet;
