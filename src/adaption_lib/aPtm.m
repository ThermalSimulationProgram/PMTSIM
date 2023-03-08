function [tinvs, tvlds, caseA_num, caseB_num] = aPtm(extBound, index, tau0, dynamicdata)

% breaktoffs2 = [];
% 
% for i = 1 : size(dynamicdata.rewardfuncs, 2)
%     breaktoffs2(:,i) =2:1:500;
% end
% temps = zeros(size(breaktoffs2));
% slopes = temps;
% for i = 1 : size(temps,2)
%     r = dynamicdata.rewardfuncs{i};
%     toffs = breaktoffs2(:,i);
%     tempat0 = r(1);
%     temps(:,i) = r(toffs);
%     slopes(:,i) = temps(:,i) - [tempat0;temps(1:end-1,i)];
%     
% end
% 
% csvwrite('extBound.csv', extBound);
% csvwrite('index.csv', index(:));
% csvwrite('tau0.csv', tau0(:));
% 
% tmp = temps';
% csvwrite('temps.csv', tmp(:));
% 
% tmp = dynamicdata.breakToffs';
% csvwrite('breakToffs.csv', tmp(:));
% tmp = breaktoffs2';
% csvwrite('breakToffs2.csv', tmp(:));
% 
% 
% tmp = dynamicdata.slopes';
% csvwrite('slopes.csv', tmp(:));
% tmp = slopes';
% csvwrite('slopes2.csv', tmp(:));
% 
% csvwrite('wcets.csv', dynamicdata.wcets(:));
% csvwrite('rho.csv', dynamicdata.rho(:));
% csvwrite('numValidData.csv', dynamicdata.numValidData(:));
% csvwrite('ncols.csv', size(dynamicdata.breakToffs,2));
% csvwrite('ncols2.csv', size(dynamicdata.rewardfuncs, 2));


wcets       = dynamicdata.wcets(index);
rho         = dynamicdata.rho(index);
k           = wcets .* rho;
if any(k>1)
    error('wrong slopes input')
end
basetinvs   = wcets .* (1-k) ./ k;
basesum     = sum(basetinvs);
rewardfuncs = dynamicdata.rewardfuncs(index);
upBound     = extBound + sum(tau0);
N           = ones(size(wcets));
breakToffs     = dynamicdata.breakToffs;
slopes      = dynamicdata.slopes;
numValidData= dynamicdata.numValidData;
numindex    = numel(index);

caseA_num = 0;
caseB_num = 0;

newnumValidData = numValidData;
for i = 1 : numindex
    for j = 1 : numValidData(i)
        if breakToffs(j, i) > basetinvs(i)
            newnumValidData(i) = j;
            breakToffs(j, i) = basetinvs(i);
            breakToffs(j+1:end, i) = 0;
            slopes(j+1:end, i) = 0;
            break;
        end
    end   
end
numValidData = newnumValidData;



if numel(tau0) ~= numindex
    error('wrong tau0 input');
end

if upBound < basesum
     
     
     % case B
     caseB_num = caseB_num + 1;
     [lambdaExt] = assigToffs(upBound-sum(tau0), index, tau0, breakToffs,...
    slopes, numValidData);
newtinvs = lambdaExt ;




%      remain = extBound;
% 
%      while remain > epsilon
%          step = remain * 0.5;
%          [newtinvs, increment] = slopeAwareToffs(newtvlds, newtinvs, step, upBound);
%          remain = remain - increment;
%      end
    
else if abs(upBound - basesum) < 1e-9
        newtinvs = basetinvs;
    else 
        %case A
        caseA_num = caseA_num + 1;
        [newtinvs, N] = assignTons(upBound, wcets, rho, rewardfuncs);
        
    end
end


tinvs = newtinvs - tau0;
tvlds = wcets .* N;





end


function d = derivative(tvlds, tinvs)

d = - tvlds ./ (tvlds + tinvs).^ 2;

end

function [toffs, increment] = slopeAwareToffs(tons, toffs, step, upBound)

    maxtoffs = upBound - sum(toffs) + toffs;

    changeId = round(toffs,8) < round(maxtoffs, 8);
    valid = changeId;
    d = abs(derivative(tons(changeId), toffs(changeId)));
    validstep = maxtoffs(changeId) - toffs(changeId);
    eachstep = step * d ./(sum(d));
    
    valid(changeId) = eachstep <= validstep;
    
    
    if all(valid(changeId))
        toffs(changeId) = toffs(changeId) + eachstep;
        increment = step;
    else
        toffs(changeId&~valid) = maxtoffs(changeId&~valid);
        increment = sum(validstep(~valid(changeId)));
        [toffs2, increment2] = slopeAwareToffs(tons(changeId&valid), ...
            toffs(changeId&valid), step-increment, maxtoffs(changeId&valid));
        toffs(changeId&valid) = toffs2;
        increment = increment + increment2;
    end

end



function [toffs, N] = assignTons(upBound, wcets, rho, rewardfuncs)
k = wcets .* rho;
ministep = wcets .* (1-k) ./ k;
numtoff = numel(wcets);
N = ones(1, numtoff);

toffs = ministep;
if any( toffs <= 0 )
    error('wrong toff');
end

go = 1;

while go
    
    sumtoff = sum(toffs);
    
    remained = upBound - sumtoff;
    
    changeId = find( round(ministep, 8) <= round(remained, 8) );
    numId = numel(changeId);
    
    if numId == 0
        break;
    end
    
    rewards = zeros(1, numId);
    for i = 1 : numId
        toffid = changeId(i);
        [values] = feval(rewardfuncs{toffid}, [toffs(toffid), toffs(toffid)+ministep(toffid)]);
        rewards(i) = (values(1) - values(2))/ministep(toffid);
    end
    
    [~, vi] = max(rewards);
    toffid = changeId(vi);
    toffs(toffid) = toffs(toffid) + ministep(toffid);
    N(toffid) = N(toffid) + 1;
end




end




