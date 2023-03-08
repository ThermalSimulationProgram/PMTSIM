function stddata = getstd_data(rstdata)

n = size(rstdata.config, 2);

step        = zeros(1 , n);
activeNum   = zeros(1 , n);
deadlines   = zeros(1 , n);


for i = 1 : n
    step(i) = rstdata.config(i).step;
    activeNum(i) = rstdata.config(i).activeNum;
    deadlines(i) = rstdata.config(i).deadline;
end

x = fields(rstdata);
x = sort(x);

type        = {'Tem', 'Time'};
for i = 1 : numel(x)
    if strcmp( x{i}, 'config')
        continue; %% x{i} == config
    end
    
    if any( rstdata.(x{i}).activeNum ~= activeNum )
        error('input data error');
    end
    algoname = strrep(x{i}, 'result',''); % sorted order, matched with x
     
    stddata.([type{1}, algoname]) = rstdata.(x{i}).miniTpeak;
    stddata.([type{2}, algoname]) = rstdata.(x{i}).exetime;
end


stddata.step        = step;
stddata.activeNum 	= activeNum;
stddata.deadlines  	= deadlines;

end