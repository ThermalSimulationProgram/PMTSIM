function sleepInterval = BWS(config)



AS_Index = config.activeSet;
SS_Index = config.sleepSet;
CCS = config.ccs;
DCS = config.dcs ;
QFIFO = config.Q;
TBET = config.TBET ;
CurTime = config.currentTime ;

sleepInterval = BWS_Dynamics(AS_Index,SS_Index,CCS,DCS,TBET,QFIFO,CurTime);

end