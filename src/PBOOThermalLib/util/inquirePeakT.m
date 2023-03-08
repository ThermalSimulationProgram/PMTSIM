function [peakTem, Timp] = inquirePeakT(TM, config, Timp, candids, index)
        acn = config.activeNum;     
        tslp = zeros(1, TM.n);
        tact = zeros(1, TM.n);
        for i = 1 : acn
            id = config.actcoreIdx(i);
            tslp(id) = candids.candidTslps{i}(index(i));
            tact(id) = candids.candidTacts{i}(index(i));
        end    
        isFast = false;
            
        [peakTem, Timp] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);