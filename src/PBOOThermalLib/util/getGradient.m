function [grd, currentT, Timp] = getGradient(currentT, TM, config, toffs, K, Timp, stepin, safeStep, direction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the gradient on point (toff)
%
%% input check and default arguments
if nargin < 6
    error('not enough inputs');
end

nvar = numel(toffs);
if nvar ~= config.activeNum
    error('input toffs size error');
end

scalor = 0.001; % unit: ms
if nargin < 7
    stepin = TM.p / scalor;    
end
if nargin < 8
    safeStep = safePeriod(K, TM.p/ scalor);
end
if nargin < 9
    degree = nvar;  % default: get the forwarding gradient towards all directions 
    direction = eye(degree); % the directions
else
    degree = size(direction, 1);
end

if size(direction, 2) ~= nvar
    error('size of direction does not argee with toff');
end

if any( sum(direction, 2) > 1 )
    error('varying in two dimensions is not support');
end

tswons = config.tswons;
tswoff = config.tswoffs;
isFast = false;

grd = zeros(1, degree);
%nstep = ceil( stepin ./ safeStep);
steps =  safeStep ;

for i = 1 : degree
    if all( direction(i,:) == 0)
        continue;
    end
    id = find( direction(i,:) ~= 0 ,1, 'first');
    temptoff = toffs + direction(i,:)*steps(id);
    [tact, tslp]= prepareTacts(temptoff, K, config);
    [tempT, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
    difference = tempT - currentT;
    slope = difference / steps(id);
    grd(i) = slope * stepin;
    %grd(i) = difference;
end




end








