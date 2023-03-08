function [Ids, temps, meant, maxt, mint, samples] = extractData(allresults)

temps = cell(1,3);
for i = 1:3
    temps{i} = zeros(size(allresults));
end
meant = temps;
maxt = temps;
mint = temps;
samples = zeros(size(allresults));

[m, n] = size(allresults);
Ids = false(m, n);

for i = 1 : m
    for j = 1 : n
        if ~isempty(allresults{i,j})
            Ids(i, j) = true;
            samples(i, j) = allresults{i,j}.config.sampleT;
            result = allresults{i,j};
            temps{1}(i,j) = getPeakT(result.aptm);
            temps{2}(i,j)  = getPeakT(result.bws);
            temps{3}(i,j)  = getPeakT(result.pboo);
            
                       
            t = getTimes(result.aptm);
            meant{1}(i,j) = t.mean;
            maxt{1}(i,j) = t.max;
            mint{1}(i,j) = t.min;
            t = getTimes(result.bws);
            meant{2}(i,j) = t.mean;
            maxt{2}(i,j) = t.max;
            mint{2}(i,j) = t.min;

        end
        
    end
    
end



end


function v = getPeakT(result)
if ~isempty(result)
    v = result.peakT;
else
    v = 0;
end

end

function t = getTimes(result)
tvec = result.pipeline.elapsetime(10:result.pipeline.adaptcounter);
t.mean = mean(tvec);
t.max = max(tvec);
t.min = min(tvec);
end
