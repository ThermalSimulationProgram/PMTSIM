function [tau, taus] = minbdf_BSF_curvedata(beta, deadline, k)
% MINBDF Computes the maximal tau of a minimal bounded delay function with
% slope being k for a given beta curve which is decribed by beta:
%           beta(i, 1)----the x coordinate of the ith point
%           beta(i, 2)----the y coordinate of the ith point
%           beta(i, 3)----the slope of the segment starting from ith point
%
%
%
% INPUT:
%    @beta:       the service demand curve data
%    boundary

% OUTPUT:
%    @tau:        the  maximal tau

%id = find(beta(:,2)>0, 1, 'first');

    MAX = deadline;

%MAX = beta(1, 1);
MIN = 0;
epsilon = 0.01;   % stop condition

% Starting with origin
%bdf = rtccurve([0 0 k]);
%
% if (rtceq(rtcmax(bdf, beta), bdf) == 0)
%   tau = 0;
%   return;
% %  error('bdf: No feasible solution for the given alpha.')
% end

go = 1;
taus = [];
while (go)
    tau = (MIN + MAX) / 2;
    
    
    if bdfprevailbeta(tau, k, beta)
        %Valid value
        MIN = tau;
        v = [tau, -1];
    else
        %Not a valid value
        MAX = tau;
        v = [tau, 1];
    end
    taus = [taus; v];
    %Stop condition
    if (MAX - MIN) < epsilon
        tau = MIN;
        go = 0;
    end
end
end


