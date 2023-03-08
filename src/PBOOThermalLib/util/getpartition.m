function [partition] = getpartition(value, range)
if nargin < 2 
    error('not enough input arguments');
end
if nargin > 2
    error('two many input arguments');
end

if numel(range) ~= 2
    error('input range must have only two elements');
end
validateattributes(range,{'numeric'},{'vector'});
lb = min(range);
ub = max(range);
validateattributes(value,{'numeric'},{'<=',ub, '>=', lb});
partition  = ( value - lb ) / (ub - lb);
end