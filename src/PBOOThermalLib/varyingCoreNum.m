function [resultData] = varyingCoreNum(TM, config, validAlgo, ifsave, saveprefix)

activeNum = config.activeNum;
if nargin < 5
saveprefix = TM.name;
end
savename = strcat(saveprefix, num2str(activeNum));
resultData.resultFBPT = results();
resultData.resultANPT = results();
resultData.resultDPA  = results();
resultData.resultBS   = results();
resultData.config     = config;
%%
if validAlgo(1)
    
    [result0] = PayBurstOnlyOnceMinimizing(TM,config,0); %brutal searching
    resultData.resultBS = result0;
    if ifsave
    save(savename, 'resultData');
    end
end

%%
if validAlgo(2)

    [result1] = PayBurstOnlyOnceMinimizing(TM,config,1); %gradient searching
    resultData.resultFBPT = result1;
    if ifsave
    save(savename, 'resultData');
    end
end

%%
if validAlgo(3)
    [result2] = PayBurstOnlyOnceMinimizing(TM,config,2); %SA
    resultData.resultANPT = result2;
   if ifsave
    save(savename, 'resultData');
    end
end


%%
if validAlgo(4)
    disp('start PDA');
    [resultDPA] = thermalDPALSCSlow(TM, config);
    resultData.resultDPA = resultDPA;
   if ifsave
    save(savename, 'resultData');
    end
end

if validAlgo(5)
    disp('start PDA fast');
    [resultDPA] = thermalDPALSCFast(TM, config);
    resultData.resultDPA = resultDPA;
   if ifsave
    save(savename, 'resultData');
    end
end





end