function [ X, Y ] = new_DE(a_a, a_i, T_inf_a, T_inf_i, T_0, tau, C_trace, pts)
%DE Simulates the thermal differential equation
%   Call: [ X Y ] = DE(a_a, a_i, T_inf_a, T_inf_i, T_0, tau, C_trace, pts)
%   Output: X is the vector of time coordinates
%           Y is the vector of corresponding temperatures
%   Input : a_a, a_i are the coefficients of the thermal model
%             in active and idle mode
%           T_inf_a, T_inf_i are the steady state temperature in active
%               and idle mode
%           T_0 is the initial temperature at t=0
%           tau is the maximal temperature
%           C_trace is the trace of the accumulated computing time
%             C_trace(:, 1) time, C_trace(:, 2) acc. computing time,  
%             C_trace(:, 3) slope
%           pts is roughly the number of calculated points in the plot
%             if pts = 0, then only temperatures at boundaries between
%             active and idle modes are determined

h_scale = 0.001; % to convert  ms to s
C_trace(:,1) = C_trace(:,1) * h_scale;
if pts == 0 % only compute temperature values at mode changes
    X = zeros(1, size(C_trace,1)); 
    Y = zeros(1, size(C_trace,1));
    X(1) = 0 ; Y(1) = T_0;
else % compute temperature values with a distance < tau/pts
    X = []; 
    Y = [];
    currenttime = 0; currenttemperature = T_0;
end

if pts == 0
    for i=1:size(C_trace,1)-1
        segment = C_trace(i,:);
        nextsegment = C_trace(i+1,:);
        X(i+1) = nextsegment(1);
        if segment(3) == 0 % mode is idle
            nexttemperature = T_inf_i + (Y(i) - T_inf_i) * ...
                exp(- a_i * (X(i+1) - X(i)));
        else              % mode is active
            nexttemperature = T_inf_a + (Y(i) - T_inf_a) * ...
                exp(- a_a * (X(i+1) - X(i)));
        end
        Y(i+1) = nexttemperature;
    end
else
    resolution = tau/pts;
    for i=1:size(C_trace,1)-1
        segment = C_trace(i,:);
        nextsegment = C_trace(i+1,:);
        XList = [currenttime:resolution:nextsegment(1)];
        if segment(3) == 0 % mode is idle
            YList = T_inf_i + (currenttemperature - T_inf_i) * ...
                exp(- a_i * (XList - currenttime));
            X = [X XList]; Y = [Y YList];
            currenttemperature = T_inf_i + (currenttemperature - T_inf_i) * ...
                exp(- a_i * (nextsegment(1) - currenttime));
        else              % mode is active
            YList = T_inf_a + (currenttemperature - T_inf_a) * ...
                exp(- a_a * (XList - currenttime));
            X = [X XList]; Y = [Y YList];
            currenttemperature = T_inf_a + (currenttemperature - T_inf_a) * ...
                exp(- a_a * (nextsegment(1) - currenttime));
        end
        currenttime = nextsegment(1);
    end
    X = [X currenttime]; Y = [Y currenttemperature];
end
end

