function core = setTime(core, setIdArray, setValueArray)
m = numel(setIdArray);
n = numel(setValueArray);
if m ~= n
    error('not match');
end
if max(setIdArray) > 4
    error('too large set id');
end
alreadySet = false(1, 4);
setValueArray = round(setValueArray/core.deltaT) * core.deltaT;
for i = 1 : m
    setId = setIdArray(i);
    if alreadySet(setId)
        error('a variable is set twice');
    end
    switch setId
        case 1
           % core.nextActiveTime = setValueArray(i);
        case 2
%             core.nextSleepTime = setValueArray(i);
%             if core.nextSleepTime > 9054 && core.nextSleepTime < 9056
%                 sss=1;
%             end
        case 3
            core.nextEventLoadTime = setValueArray(i);
        case 4
            core.eventFinishTime = setValueArray(i);
        otherwise
            error('uncorrect id');
    end
    alreadySet(setId) = true;
    
end
end