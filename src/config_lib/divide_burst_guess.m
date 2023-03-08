function trace = divide_burst_guess(trace)

trace(:,3) = [];
index = 1;
while true
    if trace(index, 2) > 1
        m = size(trace, 1);
        trace(index+2:m+1,:) = trace(index+1:m, :);
        
        trace(index+1, :) = trace(index, :);
        trace(index+1, 2) = trace(index, 2) - 1;
        trace(index, 2)   = 1;
    end
    index = index + 1;
    
    if index > size(trace, 1)
        break;
    end
    
    
end
