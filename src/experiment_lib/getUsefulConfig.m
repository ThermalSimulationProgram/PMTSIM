function uc = getUsefulConfig(c)

% input trace related
uc.tracetype         = c.tracetype;
uc.tracelen          = c.tracelen;
uc.stream            = c.stream ;
uc.deadlinefactor    = c.deadlinefactor;
uc.nstage            = c.nstage;
uc.exefactor         = c.exefactor;
uc.allwcets          = c.allwcets ;
uc.wcets             = c.wcets;
uc.inputTrace        = c.inputTrace;
% thermal model related

uc.activeCoreIdx     = c.activeCoreIdx;

% hardware related
uc.tswon             = c.tswon;
uc.tswoff            = c.tswoff;

% simulation related
uc.deltaT            = c.deltaT;              % simulation time resolution
uc.bcoef             = c.bcoef;             % the bcoef for aptm approach
uc.sampleT           = c.sampleT;               % the adaption period
uc.timeunit          = c.timeunit;
uc.dispinterval      = c.dispinterval;               % the display interval of finished events 
             

end
