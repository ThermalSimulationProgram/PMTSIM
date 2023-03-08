function B = reduceM(activeSet, sleepSet, lambda, tau, m)
% reduce the inequality sets (25)
% activeSet: the index of active stages
% sleepSet: the index of sleep stages
% lambda: a vector whose element number equals stage number, inversely
% ordered
% tau: a vector whose element number equals sleep stage number

if isempty(sleepSet) 
    B = lambda;
    return;
end
na = numel(activeSet);

B = zeros(1, na);

% extend tau to length m
fulltau = zeros(1, m);
fulltau(sleepSet) = tau;

% get the full express of right side
lambda = flip(lambda);
fullright = lambda - fulltau * tril(ones(m, m));

isSleepStage = false(1, m);
isSleepStage(sleepSet) = true;

leftvarnum = tril(ones(m))' * (~isSleepStage)';

B_i = 1;
while B_i <= na
    B(B_i) = min( fullright(leftvarnum == B_i));
    
%     if isSleepStage(varnum)
%         varnum = varnum - 1;
%         continue;
%     end
%         
%     if varnum > 1 && isSleepStage(varnum - 1)
%         B(B_i) = min( fullright(varnum-1 : varnum) );
%     else
%         B(B_i) = fullright(varnum);
%     end
    B_i = B_i + 1;
%    varnum = varnum - 1;
end

end