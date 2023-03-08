function [alpha] = historyAwareAlphaByLeakyBucket_BSW(upperBounds, ...
    curTime, stepWidth, buckets, eventArrivals)
% Use the leaky bucket approach to generate history-aware arrival curve
% for an event stream.
% INPUT:
%     @upperBounds:
%     @curTime:
%     @stepWidth:
%     @buckets:
%     @eventArrivals
%     ....
% OUTPUT:
%     @alpha:  upper arrival curve


myfactorJ = floor(curTime/stepWidth(1));
myBurstJ = buckets(1) - eventArrivals + myfactorJ;

if(myBurstJ > buckets(1))
    myBurstJ = buckets(1);
end

% myk = 1;
% while(myk * stepWidth(1) < curTime)
%     myk = myk + 1;
% end
myk = max(1, ceil(curTime/stepWidth(1)));
tmp = myk  * stepWidth(1);

if ((curTime - tmp) == 0.0)
    myoffsetJ = 0;
else
    myoffsetJ = tmp - curTime;
end

alpha = rtcaffine(upperBounds(1), 1, (-1) *  (stepWidth(1) - myoffsetJ));

if myBurstJ ~= buckets(1)
    alpha = rtcminus(alpha, (buckets(1)-myBurstJ));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if buckets(2) ~= 0
    myfactorJ = floor(curTime/stepWidth(2));
    myBurstJ = buckets(2) - eventArrivals + myfactorJ;
    
    if(myBurstJ > buckets(2))
        myBurstJ = buckets(2);
    end
    
    %     myk = 1;
    %     while(myk * stepWidth(2) < curTime)
    %         myk = myk + 1;
    %     end
    myk = max(1, ceil(curTime/stepWidth(2)));
    tmp = myk  * stepWidth(2);
    if ((curTime - tmp) == 0.0)
        myoffsetJ = 0;
    else
        myoffsetJ = tmp - curTime;
    end
    
    alpha2 = rtcaffine(upperBounds(2), 1, (-1) *  (stepWidth(2) - myoffsetJ));
    if myBurstJ ~= buckets(2)
        alpha2 = rtcminus(alpha2, (buckets(2)-myBurstJ));
    end
    
    alpha = rtcmin(alpha, alpha2);
end