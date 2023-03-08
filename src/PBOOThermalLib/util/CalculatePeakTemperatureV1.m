function [Tpeak, Timp] = CalculatePeakTemperatureV1(isFast, TM, tslp, tact, Timp,scope, nodeIdx)
% the order of cores in tslp and tact is
% the same with that in TM.
% we assume the time unit of input tslp and tact is 0.1ms!

% VERSION 1 : input arguments parser 

    % !!! isFast == 1 means that you are 100 percent sure the Timp containing the impluse responses required by
    % input tact and tslp is given, so we skip the precedures of checking
    % as well as calculating Timp.
    

N               = TM.N;
p               = TM.p;
n               = TM.n;
fftLength       = TM.fftLength;
coreIdx         = TM.coreIdx;
scalor          = 0.001; % unit ms

% pp              = inputParser;
% defaultScope    = 'global';
% defaultNodeidx  = find(TM.isCore == 1, 1);
% defaultTimp     = ImpulsePeriod2dMat(n, n);
% validScopes     = {'global', 'single','self'};
% checkScope      = @(x) any( validatestring( x, validScopes));
% checktime       = @(x) validateattributes(x, {'double', 'single'}, {'size',...
%     [1, n], 'nonnegative'});
% checkTimp       = @(x) validateattributes(x.M, {'CellImpulse'},{'size',[n,n]});
% checkid         = @(x) validateattributes(x, {'double', 'single'}, ...
%     {'scalar', 'positive', 'integer', '<=', N});
% 
% addRequired(pp, 'isFast', @islogical);
% addRequired(pp, 'TM', @isstruct);
% addRequired(pp, 'tslp', checktime);
% addRequired(pp, 'tact', checktime);
% addOptional(pp, 'Timp', defaultTimp, checkTimp);
% addOptional(pp, 'scope', defaultScope, checkScope);
% addOptional(pp, 'nodeIdx', defaultNodeidx, @(x)checkid(x));
% 
% pp.KeepUnmatched = true;
% parse(pp, isFast, TM, tslp, tact, varargin{:});
% 
% scope           = pp.Results.scope;
% nodeIdx         = pp.Results.nodeIdx;
% Timp            = pp.Results.Timp;
if ( max(TM.tend) + 2 * scalor * ( max(tact) + max(tslp) ) ) >= (fftLength * p - 5)
    error('Check the unit of tact and tslp!');
end



%%
% since only the thermal influences from non-core nodes have been considered in
% TM.Tconstmax, the thermal influences from cores should always been
% calculated
pTact           = p / scalor;          % the resolution of tact and tslp 
validSource     = true(1, n);
validTarget     = false(1, n);
%% input cases1
switch scope
    case 'global'
        validTarget     = true(1, n); 
    case 'single'
        if TM.isCore(nodeIdx) == 0
            error('Currently the thermal model can only be used for the temperature of nodes of core ');
        end
        validTarget(nodeIdx) = true;
    case 'self'
        %disp('self mode');
        if TM.isCore(nodeIdx) == 0
            error('Currently the thermal model can only be used for the temperature of nodes of core ');
        end
        if tact(nodeIdx) < pTact && tslp(nodeIdx) < pTact
        %    error('tact and tslp of the given node are less than the resolution');
        end
        validTarget(nodeIdx) = true;
        validSource     =   false(1,n);
        validSource(nodeIdx) = true;
        tact( [ 1:nodeIdx-1, nodeIdx+1:end] ) = 0;
        tslp( [ 1:nodeIdx-1, nodeIdx+1:end] ) = 0;
end

%% calculate

isAct = false( 1, n);
isAct( tact >= pTact ) = true;
validTarget = validTarget & isAct;

isPeriodic = isAct;
isPeriodic( tslp < pTact ) = false;
validSource = validSource & isPeriodic;
%% check if Timp should be calculated
%% 
if ~isFast
    % !!! isFast == 1 means that you are 100 percent sure the Timp containing the impluse responses required by
    % input tact and tslp is given, so we skip the precedure of checking
    % and calculating Timp.
    %% check if Timp already been calculated AND calculate Timp
    [Timp, TM] = completeTimp(TM, Timp, tslp, tact, validSource, validTarget, scalor);

end

%% calculate the temperature
[ Temperature] = computeTemp(TM, tslp, tact, Timp, isAct, isPeriodic);


Tpeak = max(Temperature);

