function eventArrivals=GetArrivalNum(acc_tract,CurTime)
TraceTime   = acc_tract(:,1);
index       = find(TraceTime<=CurTime);
if(isempty(index))
    eventArrivals = 0;
else
    eventArrivals = acc_tract(max(index),2);
end