function simTrace = MultiDE_fast(A, B_a, B_i, U0, D0, T_init, C_trace)
%DE Simulates the thermal differential equation
%   Call: simTrace = MultiDE(A_a, A_i, B_a, B_i, INVC, T_0, tau, C_trace, pts)
%   Output: simTrace is a cell array, where each element is 
%           of the form [X; Y]
%           X is the vector of time coordinates
%           Y is the vector of corresponding temperatures
%   Input : A_a, A_i, B_a, B_i, C are the coefficients of the thermal model
%             in active and idle mode
%           T_init is the initial temperature at t=0
%           
%           C_trace is the cell array of traces of the accumulated computing time
%             trace(:, 1) time, trace(:, 2) acc. computing time,  
%             trace(:, 3) slope
%           

h_scale = 0.001; % to convert  ms to s

T_start = T_init;

N = length(C_trace);            % node numbers
tn = size(C_trace{1},1) - 1;    % time segment number
simTrace = cell(1, N);          
X =  C_trace{1}(:, 1)' * h_scale;         % X is the time vector
Y = zeros(N, tn+1);
if tn < 1
    for k= 1 : N
        simTrace{k} = [C_trace{1,k}(1,1) ; T_init(k)];
    end
return;
end

stateMat = zeros(tn+1, N);
for i = 1 : N
    stateMat(:,i) = C_trace{i}(:,3);
end




diagIndex = 1 : N+1 : N*N;


for i = 1 : tn % time segment by time segment

    states = stateMat(i,:);
    B = ( 1 - states )'.* B_i + states' .* B_a;
    

    Y(:, i) = T_start;
    T_inf = A \ B;
    dT_tr = U0 \ (T_start - T_inf);  % U' * sqrtm(C) * (T_start - T_inf);
    t_start = X(i);                 % start time of current segment
    t_end = X(i+1);                 % end time of current segment
    diagD = D0(diagIndex);
    T_start = exp(-diagD(:) * (t_end - t_start)) .* dT_tr(:);
    T_start = U0 * T_start;          %SQRT_IC * U * T_start;
    T_start = T_start + T_inf;   
end
Y(:, end) = T_start;
for k = 1 : N
    simTrace{k} = [X; Y(k,:)];
end

end

