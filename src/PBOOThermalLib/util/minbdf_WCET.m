function [tau] = minbdf_WCET(beta,t_swoff , k)
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
%% Referenc Starting Curve
b = rtccurve([[0 0 1]]);

%Seek the Delta starting point with a slope of 1
%Update just the offset of the tangent - this lead to the upper Delta!
q = 0;  %Basic resource availability
m = 1.01;
stop = 1;
least = 0;
while (stop)
    temp = rtcaffine(b, m, q+t_swoff);
    if (rtceq(rtcmax(temp, beta), temp))
        q = q + 1;
        least = 1;
    else
        stop = 0;
    end
end
q = q - 1;


MAX = q;
MIN = - q;
epsilon = 0.1;   % stop condition

% Starting with origin
bdf = rtccurve([0 0 k]);
% 
% if (rtceq(rtcmax(bdf, beta), bdf) == 0)
%   tau = 0;
%   return;
% %  error('bdf: No feasible solution for the given alpha.')
% end

stop = 1;
while (stop)
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
    stop = 0;
  end
end

tau = floor(tau);