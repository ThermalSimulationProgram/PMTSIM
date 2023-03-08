
function result = rtccurveeq(a, b)
import ch.ethz.rtc.kernel.*;
if (a.equals(b))
    result = 1;
else
    aTemp = a;
    bTemp = b;
    aTemp.simplify();
    bTemp.simplify();
    if (aTemp.equals(bTemp))
        result = 1;
    else
        result = 0;
    end
end

end