function [simTrace, tracelength] = dynamicTemSim(TM, powerSegments, deltaT, initT)

n_units = TM.n;			% number of cores
n_nodes = TM.N;			% number of nodes


%% model matrices and vectors
INVC = TM.INVC;
A_a = TM.A_a;
A_i = TM.A_i;
B_a = TM.B_a;
B_i = TM.B_i;
U0  = TM.U0;
D0  = TM.D0;

T_inf_i = TM.initT;

if nargin < 4
initT = [];               % Initial temperature [K]
end

%% construct simulation trace
[C_trace, tracelength] = powerSeg2Trace(powerSegments, n_nodes, n_units, deltaT);

if isempty(initT)
    Tbegin = T_inf_i;
else
    Tbegin = initT;
end

%% simulation based on the thermal differential equation

%simTrace = MultiDE(A_a, A_i, B_a, B_i, INVC, Tbegin(:), C_trace);

simTrace = MultiDE_fast(A_a, B_a, B_i, U0, D0, Tbegin(:), C_trace);

% for i = 1 : numel(simTrace)
%     t1 = simTrace{i}(1,:);
%     t2 = simTrace2{i}(1,:);
%     if any( abs( t1-t2 ) > 1e-8 )
%         warning('s');
%     end
%     
%     T1 = simTrace{i}(2,:);
%     T2 = simTrace2{i}(2,:);
%     if any( abs( T1-T2 ) > 1e-8 )
%         warning('s');
%     end
% end

end
