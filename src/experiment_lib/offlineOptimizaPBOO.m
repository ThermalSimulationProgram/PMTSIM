function resultData = offlineOptimizaPBOO(config)

FTM             = config.FTM; %load('ARM8coresTM0.0001p.mat')
flp             = config.flp; %load('ARM8coresfloorplan.mat')
stream          = config.stream;
wcets           = config.allwcets;
deadlinefactor  = config.deadlinefactor;
tswon           = config.tswon;
tswoff          = config.tswoff;
step            = config.step;
nstage          = config.nstage;


alpha = rtcpjd(stream(1), stream(2), stream(3));

san = 4;


deadline = stream(1) * deadlinefactor;
config2 = ObtainConfig(alpha, deadline, wcets, tswon*ones(1, FTM.n), tswoff*ones(1, FTM.n),...
    step, nstage, flp, FTM.N, FTM.n, san);
[FTM] = completeTM(FTM, config2);
control = zeros(1,5);
control(2) = 1;
[resultData] = varyingCoreNum(FTM, config2, control, 0, '');
    
    









