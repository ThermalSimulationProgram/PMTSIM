function obj = getPTMcTrace(obj, timelength, ton, toff)

startTime = obj.currentTime; 
endTime  = startTime + timelength;
toff = floor(toff / obj.deltaT) * obj.deltaT;
ton  = ceil(ton / obj.deltaT) * obj.deltaT;
ptmsegs = ptmPowerSegs(startTime, endTime, ton, toff, obj.tswon, obj.tswoff, obj.sleep, obj.active);
obj.controlTrace = ptmsegs;
end