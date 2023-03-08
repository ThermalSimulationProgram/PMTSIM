nstage  = 3;    % stage number of pipeline 
TMcase  = 1;    % to indicate if has thermal model
switch TMcase
    case 0
        TM = [];        % no thermal model and temperature simulation
    case 1
        TM = ARM3TM();  % a 3-core ARM processor thermal model
end

% timing properties, unit millisecond
deltaT  = 0.1;  % time resolution
tswon   = 5;    % switching on time overhead
tswoff  = 5;    % switching off time overhead
displayInterval = 1;

%% construct the pipeline
obj = Pipeline(TM, nstage, tswon*ones(1, nstage), tswoff*ones(1, nstage),...
    deltaT, displayInterval);


%% generate inputs
stream = [100, 150, 0];
deadlinefactor = 1.2;
wcets = [14.2, 9, 3.6];
tracetype = 0;
tracelen = 60000;
exefactor = 1;
inputTrace = generateInput(nstage, stream, deadlinefactor, wcets,...
                        tracetype, tracelen, exefactor);

obj = getInputs(obj, inputTrace);

examplecase = 4; % four examples



switch examplecase
    case 1
        kdata.kernel = 'GE';
    case 2
        kdata.kernel = 'PTM';
        kdata.tons  = [15.2, 10, 4.6];
        kdata.toffs = [9.3, 14.8, 16.7];
    case 3
        kdata.kernel = 'BWS';
        kdata.adaptPeriod = 100;
    case 4
        kdata.kernel = 'APTM';
        kdata.adaptPeriod = 100;
        kdata.bcoef = 0.93;
        load('offlineDataARM3cores.mat');
        kdata.offlineData = offlineData;
end

obj.saveconfig = false;

obj = setKernel(obj, kdata);
obj = extendedResetPipeline(obj);

for i = 1:1000
    obj = simulateToNextAdaption(obj);
    obj = pipelineAdaption(obj);
end
peakT = getPeakTemperature(obj);
T1_Trace = getTemperatureTrace(obj,1);











    
    
