function [isAct, isPeriodic] = obtainFlags(tact, tslp, pToffTon)
isAct = (tact >= pToffTon);  % same unit: ms
isPeriodic = isAct;
isPeriodic( tslp < pToffTon ) = false;
end