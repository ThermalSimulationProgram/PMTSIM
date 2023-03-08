function simTrace = MultiDE(A_a, A_i, B_a, B_i, INVC, T_init, C_trace)
%DE Simulates the thermal differential equation
%   Call: simTrace = MultiDE(A_a, A_i, B_a, B_i, INVC, T_0, tau, C_trace, pts)
%   Output: simTrace is a cell array, where each element is 
%           of the form [X; Y]
%           X is the vector of time coordinates
%           Y is the vector of corresponding temperatures
%   Input : A_a, A_i, B_a, B_i, C are the coefficients of the thermal model
%             in active and idle mode
%           T_init is the initial temperature at t=0
%           tau is the maximal temperature
%           C_trace is the cell array of traces of the accumulated computing time
%             trace(:, 1) time, trace(:, 2) acc. computing time,  
%             trace(:, 3) slope
%           pts is roughly the number of calculated points in the plot

h_scale = 0.001; % to convert  ms to s
%h_scale = 1/200000; % convertion from 1000 cycles to s (MPARM specific)
%pts = max(pts, 0); % pts should not be 0

IC = INVC;
%SQRT_IC = sqrtm(IC); % SQRT_IC = C^{-1/2}
%resolution = tau/pts;
T_start = T_init;

if size(C_trace{1},1)-1 < 1
    for k= 1 : length(C_trace)
        simTrace{k} = [C_trace{1,k}(1,1) ; T_init(k)];
    end
return;
end



X = [];
Y = [];
for i=1:size(C_trace{1},1)-1 % time segment by time segment
    % determine the A, B matrices corresponding to this segment
    A = A_a;
    B = B_a;
    for k=1:length(C_trace) % for each node of the network
        if C_trace{k}(i,3) == 0 % mode is idle
            A(k,k) = A_i(k,k);  % replace diagonal element
            B(k) = B_i(k);
        end
        if C_trace{k}(i,3) == 1
            A(k,k) = A_a(k,k);  % replace diagonal element
            B(k) = B_a(k);          
        end
        if C_trace{k}(i,3) > 0 && C_trace{k}(i,3) < 1
            %A(k,k) = A_u(k,k);  % replace diagonal element
            %B(k) = B_u(k);     
            A(k,k) = A_a(k,k);
            B(k) = ( 1 - C_trace{k}(i,3) ) * B_i(k) + C_trace{k}(i,3) * B_a(k);
            %error('ERROR'); 
        end     
    end
    % Determine result using eigenvalue decomposition
    [U, D] = eig(IC * A); %eig(SQRT_IC * A * SQRT_IC);
    T_inf = A \ B;
    dT_tr = U \ (T_start - T_inf); % U' * sqrtm(C) * (T_start - T_inf);
    t_start = C_trace{1}(i,1); % start time of current segment
    t_end = C_trace{1}(i+1,1);   % end time of current segment
    t_iter = [t_start]; % list of analysis times
    X = [X t_iter]; 
    %X = [X t_end]; % append new times to vector of times
    T_iter =  []; T_start = [];
    for k=1:length(C_trace) % for each node of the network
        T_iter(k,:) =  exp(- D(k,k) * (t_iter - t_start) * h_scale ) * dT_tr(k,1);
        T_start(k,1) =  exp(- D(k,k) * (t_end - t_start) * h_scale ) * dT_tr(k,1);
    end
    % renormalize the temperatures
    T_iter = U * T_iter; % SQRT_IC * U * T_iter;
    for k=1:length(C_trace) % for each node of the network
        T_iter(k,:) = T_iter(k,:) + T_inf(k);
    end
    Y = [Y T_iter]; % append to vector of temperatures
    T_start = U * T_start; %SQRT_IC * U * T_start;
    T_start = T_start + T_inf;
    %Y = [Y T_start];  % append to vector of temperatures
    
    % Add the last time and temperature to the vector
    if (i == size(C_trace{1},1)-1)
        X = [X t_end];
        Y = [Y T_start];
    end
end

for k=1:length(C_trace)
    simTrace{k} = [X*h_scale ; Y(k,:)];
end

end

