function obj = updateTemTrace(obj, startTime, endTime, slope)
% timelength = endTime - startTime;
% % temperature trace
% numtimevector = round(timelength/obj.deltaT);
% timevector = obj.resolution * ( 0 : 1 : numtimevector-1);
% timevector = timevector(:)';
% slopevector = slope * ones(numel(timevector), 1);
% localTrace = [];
% localTrace(:,1) = timevector + startTime;
% localTrace(:,3) = slopevector;
% obj.cTrace = [obj.cTrace; localTrace];

newtrace = [startTime , endTime , slope];
newtrace = [obj.cTrace; newtrace];

obj.cTrace = newtrace;

end