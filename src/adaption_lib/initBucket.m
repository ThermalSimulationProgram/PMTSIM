function [buckets, stepWidths, upperBounds] = initBucket(period, jitter, delay)

approxRange = 10;

if (delay>0) && (delay>period-jitter)
    buckets(1) = 1;
    buckets(2) = ceil(jitter/period);
    upperBounds(1) = rtcpjdu(delay, 0, 0);
%    upperBounds(2) = rtcpjdu(period, period*(buckets(2)-1), 0);
    upperBounds(2) = rtcpjdu(period, jitter, 0);
    stepWidths(1) = delay;
    stepWidths(2) = period;

    
    % Approximate those curves
    upperBounds(1) = rtcapproxs(upperBounds(1), approxRange*delay, 0, 1);
    upperBounds(2) = rtcapproxs(upperBounds(2), approxRange*period, 0, 1);
    
%    a = rtcpjdU(period, jitter, delay);
%    b = rtcmin(upperBounds(1), upperBounds(2));
%    rtcplot(a, 'b', b, 'r', upperBounds(1), 'y', upperBounds(2), 'g-*',800);

else
    % only one bucket
    buckets(1) = ceil(jitter/period);
    buckets(2) = 0;   
%    upperBounds(1) = rtcpjdu(period,  period*(buckets(1)-1), 0);
    upperBounds(1) = rtcpjdu(period,  jitter, 0);
    upperBounds(2) = rtccurve([0 0 0]);
    stepWidths(1) = period;
    stepWidths(2) = 0;
    
    % Approximate those curves
    upperBounds(1) = rtcapproxs(upperBounds(1), approxRange*period, 0, 1);
end
%upperBounds = rtcpjdU(stepWidth,  ((stepWidth * (buckets-1))), 0);