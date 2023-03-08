function [Tpeak, Timp, TM] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp)
% the order of cores in tslp and tact is
% the same with that in TM.
% the time unit is milisecond!

%VERSION 3: fixed input arguments, no input arguments checking, fast
%algorithm

    % !!! isFast == 1 means that you are 100 percent sure the Timp containing the impluse responses required by
    % input tact and tslp is given, so we skip the precedure of checking
    % and calculating Timp.
    

N               = TM.N;
p               = TM.p;
n               = TM.n;

scalor          = 0.001; % unit ms

%%
% since the thermal influences from non-core nodes have been considered in
% thermal model, only the thermal influences from cores should always been
% calculated
pTact = TM.p / scalor;          % the resolution of tact and tslp 

%% isAct and isPeriodic 
% indicates if Timp(i,j) can be skipped and if the  
% impulse response from corresponding node is independent from tact and tslp; 

isAct = false( 1, n);
isAct( tact >= pTact ) = true;
isPeriodic = isAct;
isPeriodic( tslp < pTact ) = false;

if ~isFast
    % !!! isFast == 1 means that you are 100 percent sure the Timp containing the impluse responses required by
    % input tact and tslp is given, so we skip the precedure of checking
    % and calculating Timp.
    %% check if Timp already been calculated and calculate Timp
    [Timp, TM] = completeTimp(TM, Timp, tslp, tact, isPeriodic, isAct, scalor);

end


%% calculate the temperature
Temperature = computeTempQuick(TM, tslp, tact, Timp, isAct, isPeriodic);

Tpeak = max(Temperature);

