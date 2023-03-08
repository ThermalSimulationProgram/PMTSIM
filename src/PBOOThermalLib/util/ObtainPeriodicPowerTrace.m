function [P, sample_period, maxIndex] = ObtainPeriodicPowerTrace(Pa, Pi, tact, tslp, length, p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns a periodic power trace
% Pa            the active state power
% Pi            the sleep state power
% tact          the time interval length of active state
% tslp          the time interval length of sleep state
% length        the length of the power trace
% p             resolution of time
% all time variable in same unit : second
% author:       long
% version:      1.0  01/02/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check
if tact < p || tslp < p
    error('given tact and tslp should be larger than resolution p');
end
% the max index of the power trace
maxIndex        = ceil( length / p );
period          = tact + tslp;
sample_period   = round( period / p );
n_periods       = ceil( maxIndex / sample_period);
sample_tact     = round(tact/p);
% start with active state, followed by sleep state
single_p        = [ Pa*ones(1, sample_tact) , ...
                    Pi*ones(1, sample_period - sample_tact)];                
P               = repmat(single_p, 1, n_periods);