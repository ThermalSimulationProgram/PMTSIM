function C_trace = traceGenerateForMultiDE(tau,p,ton,toff)
period = ton+toff;
index = 1;

if ton == 0
    for t=0:p:tau
        C_trace(index,1)=t;
        C_trace(index,3)=0;
         index = index +1;
    end
else
    
   period_n = ceil(tau/period);
   sig_p = [];
   t=0;
   while t<= period
       if mod(t,period) <= ton
            sig_p(index ) = 1;
        else
            sig_p(index )= 0;
       end
       t = t +p;
       index  = index +1;
   end
   full_p  = powerTrace(sig_p,period_n);
   
   
   C_trace(:,1)=(0:p:tau)';   
   C_trace(:,3) = (full_p(1:size(C_trace(:,1),1)))';
   
end

