function [Opt_trace2] = Trace_generate(t_off_opt,t_on_opt, ins_n, t_off_insert,t_on_insert,tau)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Generate the trace for function [DE] , all variable have the same
%%%  unit 'ms'
%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t=t_on_opt + t_off_opt + (t_on_insert + t_off_insert) * ins_n;
num_period= floor(tau / t)+1;
sect_n = 2 + 2*ins_n;
Opt_trace2=zeros(sect_n *num_period, 3);
Opt_trace2(1 , :) =  [ 0 0 0 ];
for period = 1:1:num_period
    
    Opt_trace2((period-1)*sect_n + 2 , 1) = Opt_trace2((period-1)*sect_n + 1 , 1) + t_off_opt ;
    Opt_trace2((period-1)*sect_n + 2 , 2) = Opt_trace2((period-1)*sect_n + 1, 2) ;
    
    if ins_n >= 1
        for j = 1:1:ins_n
            Opt_trace2((period-1)*sect_n + 1 + j*2, 1) = Opt_trace2((period-1)*sect_n + j*2 , 1) + t_on_insert;
            Opt_trace2((period-1)*sect_n + 1 + j*2, 2) = Opt_trace2((period-1)*sect_n + j*2 , 2) + t_on_insert;
            Opt_trace2((period-1)*sect_n + 2 + j *2 , 1) = Opt_trace2((period-1)*sect_n + 1 + j *2 , 1) + t_off_insert;
            Opt_trace2((period-1)*sect_n + 2 + j *2 , 2) = Opt_trace2((period-1)*sect_n + 1 + j *2 , 2) ;
        end
        Opt_trace2(period*sect_n + 1 , 1) = Opt_trace2(period*sect_n , 1) + t_on_opt ;
        Opt_trace2(period*sect_n + 1 , 2) = Opt_trace2(period*sect_n , 2) + t_on_opt ;
    else
        Opt_trace2(period*sect_n + 1 , 1) = Opt_trace2(period*sect_n , 1) + t_on_opt ;
        Opt_trace2(period*sect_n + 1 , 2) = Opt_trace2(period*sect_n , 2) + t_on_opt;
    end
end


for i=2:1: sect_n*num_period
    if mod(i , 2) ==1
        Opt_trace2(i , 3) = 0;
    else
        Opt_trace2(i , 3) = 1;
    end
end
end

