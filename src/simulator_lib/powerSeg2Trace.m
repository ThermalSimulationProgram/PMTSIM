function [C_trace, globalLength]= powerSeg2Trace(powerSegs, n_nodes, n_units, deltaT)

C_trace = cell(1, n_nodes);

tstart = zeros(1, n_units);
tend = tstart;

if numel(powerSegs) ~= n_units
    error('not complete power segments');
end

for i = 1 : n_units
    if isempty(powerSegs{i})
        continue;
    end
    tstart(i) = powerSegs{i}(1, 1);
    tend(i) =  powerSegs{i}(end, 2);
end

startTime = max(tstart);
endTime = max(tend);

veclength = round(endTime/deltaT) - round(startTime/deltaT);
timevec = deltaT * (0:1:veclength-1);

globalLength = numel(timevec);


for i = 1 : n_units
    if isempty(powerSegs{i})
        ptrace = [startTime, endTime, 0]; % assume nonactive cores sleep
    else
        ptrace = powerSegs{i};
    end
    
    ptrace(:,3) = round(ptrace(:,3)/deltaT)*deltaT;
    segments = round(ptrace(:, 1:2)/deltaT);
    numpoint = segments(:,2) - segments(:,1) ;
    strace = zeros(globalLength, 1);
    
    lowIndex = 1;
    for j = 1 : numel(numpoint) 
        bigIndex = min(globalLength, lowIndex + numpoint(j)-1);
%         if ptrace(j,3)~=1 && ptrace(j,3)~=0
%             error('power state error, should be 0 or 1');
%         end
        strace(lowIndex:bigIndex) = ptrace(j,3);
        lowIndex = bigIndex + 1;
    end
    
    ctrace = zeros(globalLength, 3);
    ctrace(:,1) = timevec;
    ctrace(:,3) = strace;
    C_trace{i} = ctrace;

end

for i = n_units+1 : n_nodes
    C_trace{i} = zeros( size(C_trace{1}) );
end

