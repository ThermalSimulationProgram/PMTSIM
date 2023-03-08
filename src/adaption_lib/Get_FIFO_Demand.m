function curveData = Get_FIFO_Demand(WCET, FIFO, CurTime, trace_org, load, OnGoEventID)
Q           = FIFO.Q;
curveData   = [0 0 0];
xvalue0     = 0;
%if(load==trace_org(OnGoEventID,3+index)) %if on going event is not start, then accounted as event in FIFO

if isempty(OnGoEventID) 
    if load > 0
        warning('No event is handled, load should be zero!');
    end
    load = 0;
end
    
if( load > 0)
    % trace_org(OnGoEventID, 3): abosulte deadline
    % xvalue: relative deadline
    xvalue = trace_org(OnGoEventID, 3) - CurTime;
    remained_part = load/WCET;
    if(xvalue > xvalue0)
        curveData   = [ curveData; [ xvalue, curveData(end, 2) + remained_part, 0]];
        xvalue0     = xvalue;
    else
        if( xvalue == xvalue0)
            curveData(end,2) = curveData(end,2)+1;
            xvalue0 = xvalue;
        else
            error('Not increasement!!!');
        end
    end
end
for i = 1 : Q
    eventID = FIFO.buf(i, 1);
    xvalue  = trace_org(eventID, 3) - CurTime; %deadline
    if(xvalue > xvalue0)
        curveData   = [curveData;[xvalue,curveData(end,2)+1,0]];
        xvalue0     = xvalue;
    else
        if(xvalue   == xvalue0)
            curveData(end,2) = curveData(end,2)+1;
            xvalue0 = xvalue;
        else
            error('Not increasement!!!');
        end
    end
end
%curve = rtccurve(curveData);