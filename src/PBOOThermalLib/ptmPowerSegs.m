function ptmsegs = ptmPowerSegs(startTime, endTime, ton, toff, minton, mintoff, sleep, active)
%% sanity check
if  any( [startTime, endTime, ton, toff, endTime - startTime] < 0 )
    error('input time must be nonnegative')
end
if ton < minton && toff < mintoff
 %   error('incorrect PTM parameter: ton and toff must be larger than switching overhead');
end
if ton < minton
    ptmsegs = [sleep, startTime, endTime];
    return;
end
if toff < mintoff
    ptmsegs = [active, startTime, endTime];
    return;
end

if isinf(ton)
    ptmsegs = [active, startTime, endTime];
    return;
end

if isinf(toff)
    ptmsegs = [sleep, startTime, endTime];
    return;
end


deltaT = 0.001;
toff = round(toff / deltaT) * deltaT;
ton  = round(ton / deltaT) * deltaT;
%%
period = ton + toff;
% the partition of toff 
slope = toff / period;
% accurate calculate how many periods 
xPTM =  (endTime - startTime)/period ;
fullPTM = floor(xPTM);

if fullPTM < 1
    
    if toff >= (endTime - startTime)
        ptmsegs = [sleep, startTime, endTime];
        return;
    else
        ptmsegs = [sleep, startTime, startTime + toff];
        ptmsegs = [ptmsegs; active, startTime + toff, min(endTime, startTime + toff + ton)];
        return;       
    end
  
end

residue = xPTM - fullPTM;

if residue > slope
    numctrl = fullPTM * 2 + 2;
else if residue > 0
        numctrl = fullPTM * 2 + 1;
    else
        numctrl = fullPTM * 2;
    end
end

vector = 1 : numctrl;
vector1 = mod( vector, 2 );

trace1 = vector1 * sleep + (1 - vector1) * active;
trace3 = ceil( vector / 2 )*period - vector1 * ton + startTime;
if endTime - trace3(end) > deltaT
    error('unknown error');
end
trace3(end) = endTime;
trace2 = [startTime, trace3(1:end-1)];

ptmsegs = [trace1(:), trace2(:), trace3(:)];