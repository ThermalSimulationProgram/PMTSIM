function [tau, taus] = minbdf_BSF(beta,deadline,k)
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
MIN = 0;
epsilon = 0.001;   % stop condition

% Starting with origin
%bdf = rtccurve([0 0 k]);
% 
% if (rtceq(rtcmax(bdf, beta), bdf) == 0)
%   tau = 0;
%   return;
% %  error('bdf: No feasible solution for the given alpha.')
% end
if ~isa(beta,'ch.ethz.rtc.kernel.Curve')
    error('wrong input beta');
end
import ch.ethz.rtc.kernel.*;
go = 1;
taus = [];
while (go)
  tau = (MIN + MAX) / 2;
  
  temp = rtccurve([0,0,0; tau, 0, k]);
  
  if rtccurveeq(CurveMath.max(temp,beta), temp)
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
