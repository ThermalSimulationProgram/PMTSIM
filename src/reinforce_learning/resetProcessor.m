function [InitialObservation, loggedSignals] = resetProcessor()

% nstage  = 3;    % stage number of pipeline 
% TM = ARM3TM();  % a 3-core ARM processor thermal model

nstage  = 1;    % stage number of pipeline 
TM = singleCoreTM();  % a SINGLE-core ARM processor thermal model


% timing properties, unit millisecond
deltaT  = 0.1;  % time resolution
tswon   = 1;    % switching on time overhead
tswoff  = 1;    % switching off time overhead
displayInterval = 10;

%% construct the pipeline
obj = Pipeline(TM, nstage, tswon*ones(1, nstage), tswoff*ones(1, nstage),...
    deltaT, displayInterval);



obj = extendedResetPipeline(obj);

state = getPipelineStateWithPrediction(obj);
loggedSignals.State = state;
loggedSignals.obj = obj;
InitialObservation = state;
disp('The env is reset in [resetProcessor.m]');


end