function k= minspeedbdfEDG_curvedata(beta, delay,step)
% MINBDF Computes the minmum speed by given the delay and demand sevice curve.
%
% k= minspeedbdfEDG(bdf, delay)
%
% INPUT:
%    @beta:        the service bound curve
%    @delay:      the delay

% OUTPUT:
%    k:           minumu speed
% author: Gang Chen     cheng@in.tum.de
max_speed=1;
min_speed=0;
if step>= 5 % stop condition
epsilon = 10^(-3); 
else
    epsilon = 10^(-5);
end 
stop = 1;


while (stop)
  %if max_speed curve is greater than beta
  mid_speed=(max_speed+min_speed)/2;
  %bdf_mid = rtccurve([0 0 0;delay,0, mid_speed]);
 % bdf_mid = rtcaffine(bdf_mid, 1, delay);
  if bdfprevailbeta(delay, mid_speed, beta) 
    %Valid value
    max_speed = mid_speed;
  else
    %Not a valid value
    min_speed = mid_speed;
  end  
  %Stop condition
  if (max_speed - min_speed) < epsilon
    k = max_speed;
    stop = 0;
  end
end

