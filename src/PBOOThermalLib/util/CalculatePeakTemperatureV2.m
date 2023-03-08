function [Tpeak, Timp,TM] = CalculatePeakTemperatureV2(isFast, TM, tslp, tact, Timp)

% the order of cores in tslp and tact is
% the same with that in TM.
% the time unit is milisecond!

%VERSION 2: fixed input arguments, no input arguments checking

    % !!! isFast == 1 means that you are 100 percent sure the Timp containing the impluse responses required by
    % input tact and tslp is given, so we skip the precedure of checking
    % and calculating Timp.
    

n               = TM.n;

scalor          = 0.001; % unit ms

if ( max(TM.tend) + 2 * scalor * ( max(tact) + max(tslp) ) ) >= (TM.fftLength * TM.p - 5)
    error('Check the unit of tact and tslp!');
end



%%
% since only the thermal influences from non-core nodes have been considered in
% TM.Tconstmax, the thermal influences from cores should always been
% calculated
pTact = TM.p / scalor;          % the resolution of tact and tslp 

%% isAct and isPeriodic indicates if Timp(i,j) can be skipped

isAct = ( tact >= pTact );
isPeriodic = isAct;
isPeriodic( tslp < pTact ) = false;


%% 
if ~isFast
    % !!! isFast == 1 means that you are 100 percent sure the Timp containing the impluse responses required by
    % input tact and tslp is given, so we skip the precedure of checking
    % and calculating Timp.
    %% check if Timp already been calculated AND calculate Timp
    [Timp, TM] = completeTimp(TM, Timp, tslp, tact,   isPeriodic, isAct, scalor);
end


%% calculate the temperature
[ Temperature] = computeTemp(TM, tslp, tact, Timp, isAct, isPeriodic);

Tpeak = max(Temperature);

