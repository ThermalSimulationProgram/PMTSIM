function TM = AMDThermalModel()

try
    % try load data from the file
    load('AMDCPU_ThermalModel.mat');
    g = m;
catch
    warning('error in loading model parameter file! using the default parameters');
    Tinf_a = 322.15;
    Tinf_i = 296.15;
    g = 0.037;
end

TM.T_inf_a  = Tinf_a;
TM.T_inf_i  = Tinf_i;

TM.g_a      = g;
TM.g_i      = g;

TM.n = 1;
TM.N = 1;

TM.initT = Tinf_i;