function l = safePeriod(Kin, p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function calculates the periods of the round error.
%  accurate ton = k/(1-k)*toff
%  approximated ton is the accurate ton rounded with resolution p
%  error = approximated ton - accurate ton
%  Therefore, when toff increases in a fixed step, the error varies
%  periodically, where the period is related to k.
%
%  author: Long
%  version: 1.0, 06/03/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% prepare data
% default length of the trace of toff
n = 10000;
% default toff
toff = 10;
% tolerance of error, used to remove the tiny noises caused by float operations.
% when max error is less than it, we consider error==0
tolerance = 1e-12;
% generate traces of toff, real ton, and approximated ton
toffs = toff: p : (toff+n*p);
nvar = numel(Kin);
l = zeros(1, nvar);
for i = 1 : nvar
    K = Kin(i);
    realtons = K/(1-K)*toffs;
    apptons = round(realtons / p) * p;
    %% calculate error
    error = apptons - realtons;
    % determine if error equals 0 actually
    if max(error) < tolerance
        l(i) = p;
        continue;
    end
    
    %% post processing
    % assistant vector, used to calculate the difference between two
    % consecutive elements in error.
    % s(i) = error(i-1)
    error2 = [-inf,error(1:end-1)];
    
    
    % the difference. first element should not be used
    % difference(i) = error(i) - s (i) =  error(i) - error(i-1)
    difference = error - error2;
    
    % assistant difference vector, difference2(i) = difference(j+1)
    difference2 = [difference(2:end),-1];
    
    % we want to find the local minimas in the trace of error
    % the local minimas satisfy following inequalities, if its index is j:
    % error(j) - error(j-1) = difference(j) < 0
    % error(j+1) - error(j) = difference2(j) > 0
    ids1 = find( (difference < 0));
    ids2 = find( (difference2 > 0));
    
    % get the intersect of two ids, which is the real index of local mimimas
    ids = intersect(ids1, ids2);
    if numel(ids) > 3
        l(i) = ( ids(3)-ids(2))*p;
    else
        % not enough local miminas has been found...
        l(i) = -1;
    end
    
end

end