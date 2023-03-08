function [Index flag] = updateIndex(digit, limit, oldIndex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updateIndex updates the oldIndex with an increment 1 under the given
% limit.
% Inputs:
%       digit       indicates how many digits the number has
%       limit       the limit for every digit of the number
%       oldIndex    the index to be updated
%
% Output:
%       Index       the updated index
%       flag        indicates if all the upper limits have been touched
%
% author: Long Cheng
% version:  1.0     date lost
%           1.1     add function introduction 1/11/2015.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin < 3
    error('not enough input arguments!');
end

if ~isvector(limit) || ~isvector(oldIndex)
    error('limit or oldIndex should be a vector!');
end

if max( size(limit) ) ~= max (size(oldIndex)) ||...
        max( size(limit) ) ~= digit
    error('size of limit and oldIndex should equal digit');
end

if min( oldIndex <= limit) < 1
    error('input oldIndex should be smaller than limit');
end

if min( limit == fix(limit) ) < 1 || ...
   min( oldIndex == fix(oldIndex) ) < 1
    error('limit and oldIndex should be integers');
end

%%

Index = oldIndex;
flag = 0;

if digit == 1
    if Index < limit
        Index = Index + 1;
    else
        Index = 1;
        flag = 1;
    end
    
else
    if Index(digit) < limit(digit)
        Index(digit) = Index(digit) + 1;
    else
        Index(digit) = 1;
        [Index( 1 : digit-1 ), flag]  = updateIndex(digit-1, limit( 1 : digit -1), Index( 1 : digit-1 ));
    end
end
end