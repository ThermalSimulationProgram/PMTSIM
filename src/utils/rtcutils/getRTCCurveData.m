function [flag, curvedata] = getRTCCurveData(a)
curvedata = [];
flag = false;
if ~a.hasPeriodicPart
    curvestring = rtcexport(a);
    flag = true;
    if ~strcmp(curvestring(1:9), 'rtccurve(')
        flag = false;
    else
        data = curvestring(10:end-1);
        try
            curvedata = eval(data);
            if size(curvedata, 2) ~= 3
                flag = false;
            end
        catch
            flag = false;
        end
    end
end

