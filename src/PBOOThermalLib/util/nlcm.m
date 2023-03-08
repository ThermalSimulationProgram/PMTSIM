function [b] = nlcm(a,p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculates the least common multiple of n positive real numbers
% Input:
%       a       the vector containning the positive real numbers
%       p       the resolution
% Output:
%       b       the least common multiple of the real numbers in a
%
% version:  1.0
% author:   Long Cheng
% date:     3/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = size(a,2);
b = 1;
ra  = round( a / p);
% if  any( ra <= 0)
%     error('after casting with resolution p, a must be a positive real number vector')
% end
if  any( ra <= 0)
    b = 0;
    return
end
for i = 1 : n
    b = lcm(b, ra(1,i));
end
b = b * p;

