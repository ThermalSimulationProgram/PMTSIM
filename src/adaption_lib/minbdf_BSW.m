function [tau] = minbdf_BSW(beta,deadline,k)
% MINBDF Computes the maximal tau of a minimal bounded delay function for
% a given alpha curve, i.e., EQ.4 in the paper by binary search. The
% slope of the bounded delay function is always 1.
%
% [tau] = MINBDF(betaA)
%
% INPUT:
%    @beta:       the service demand curve
%    @deadline:   the relative deadline of this stream, only for bsearch
%    boundary

% OUTPUT:
%    @tau:        the  maximal tau

MAX = deadline;
MIN = - deadline;
epsilon = 0.000001;   % stop condition

% Starting with origin
bdf = rtccurve([0 0 k]);
% 
% if (rtceq(rtcmax(bdf, beta), bdf) == 0)
%   tau = 0;
%   return;
% %  error('bdf: No feasible solution for the given alpha.')
% end

go = 1;
while (go)
  tau = (MIN + MAX) / 2;
  temp = rtcaffine(bdf, 1, tau);
  
  if (rtceq(rtcmax(temp, beta), temp))
    %Valid value
    MIN = tau;
  else
    %Not a valid value
    MAX = tau;
  end
  %Stop condition
  if (MAX - MIN) < epsilon
    tau = MIN;
    go = 0;
  end
end

tau =tau;