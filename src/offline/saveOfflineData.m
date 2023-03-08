function [] = saveOfflineData(offlinedata, prefix)	


mtdata = offlinedata.mtdata;
[breakToffs, slopes, numValidData] = trans2matForMTtable(mtdata);
csvwrite([prefix, '_coolBreakToffs.csv'], breakToffs);
csvwrite([prefix, '_coolslopes.csv'], slopes);
csvwrite([prefix, '_numValidData.csv'], numValidData(:));



slopedata = offlinedata.slopedata;
nstages = numel(slopedata{1});
nslopes = numel(slopedata);


for i = 1 : nstages
    A = [];
    D = [];
    for j = 1 : nslopes
        B = [];
        r = slopedata{j}{i};
        toffs = 2:200;
        temps = r(toffs);
        temps = temps(:)';
        tempat0 = r(1);
        slopes = temps - [tempat0, temps(1:end-1)];
        
   
        B = [toffs; temps; slopes];
        
        D = [D, numel(toffs)];
        A = [A, B];
        
    end
    
    csvwrite([prefix, '_warmingdata', num2str(i), '.csv'], A);
    csvwrite([prefix, '_warmingdataNumber', num2str(i), '.csv'], D');
    
end


csvwrite([prefix, '_slopestep.csv'], 1);
end
