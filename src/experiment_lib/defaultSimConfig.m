function c = defaultSimConfig()

% input trace related
c.tracetype         = 0;
c.tracelen          = 15000;
c.stream            = [100, 150, 0];
c.deadlinefactor    = 1.2;
c.nstage            = 8;
c.exefactor         = ones(1, 8);
c.allwcets          = [5.2;3.5;4.6;4.8;6;3;3.6;5.6];
c.wcets             = [5.2;3.5;4.6;4.8;6;3;3.6;5.6];
c.inputTrace        = generateInput(c.nstage, c.stream, c.deadlinefactor, c.wcets,...
                        c.tracetype, c.tracelen, c.exefactor);
% thermal model related
load('offlineDataARM8cores.mat');
load('ARM8coresTM0.0001p.mat');
load('ARM8coresfloorplan.mat');
c.TM                = ARM8TM();
c.FTM               = TM;
c.flp               = flp;
c.allofflineData    = offlineData;
c.offlineData       = offlineData;
c.activeCoreIdx     = 1 : 8;

% hardware related
c.tswon             = 1;
c.tswoff            = 1;

% simulation related
c.deltaT            = 0.1;              % simulation time resolution
c.bcoef             = 0.94;             % the bcoef for aptm approach
c.sampleT           = 20;               % the adaption period
c.timeunit          = 'ms';
c.dispinterval      = 25;               % the display interval of finished events 
c.hasPbooResult     = false;
c.resultData        = [];
c.step              = 1;                % offline pboo optimize step



end