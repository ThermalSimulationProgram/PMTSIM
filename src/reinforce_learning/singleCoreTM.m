function TM = singleCoreTM()

C = 0.03;       % thermal capacity [J/K]
T0 = 300.0;     % environment temperature [K]
G = 0.3;        % thermal conductance [W/K]
alpha_a = 0.1;  % slope of power in active mode [W/K]
alpha_i = 0.1;  % slope of power in idle mode [W/K]
beta_a = -11;   % constant power in active mode [W]
beta_i = -25;   % constant power in idle mode [W]

a_a = (G - alpha_a)/C;     % linear coefficient of DE in active mode
a_i = (G - alpha_i)/C;     % linear coefficient of DE in idle mode
b_a = (beta_a + G * T0)/C; % constant of DE in active mode
b_i = (beta_i + G * T0)/C; % constant of DE in idle mode

T_inf_a = b_a/a_a;         % steady state temperature in active mode
T_inf_i = b_i/a_i;         % steady state temperature in idle mode

TM.n = 1;
TM.N = 1;
TM.A_a = a_a;
TM.A_i = a_i;
TM.B_a = b_a;
TM.B_i = b_i;
TM.g_a = a_a;
TM.g_i = a_i;
TM.initT = 300;
TM.inifT_a = T_inf_a;
TM.inifT_i = T_inf_i;
TM.T_inf_a = T_inf_a;
TM.T_inf_i = T_inf_i;