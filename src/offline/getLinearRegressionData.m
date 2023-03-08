function [LR_Data] = getLinearRegressionData(alldata, numseg)

nslopes = numel(alldata);
LR_Data = cell(1, nslopes);

if nargin < 2
    numseg = [];
end

if isempty(numseg)
    numseg = 4;
end

minseglength = 1; % at least two points are required to get the slope

for i = 1 : nslopes
    i
    data = alldata{i};
    nstage = numel(data);
    tempdata = cell(1,3);
    for j = 1 : nstage
        T = data{j}(1,:);
        toff = data{j}(2,:);

%         table = [];

%         
%         numexmpl = numel(T);
%         
%         if numexmpl > numseg + 4
%             nknots = (numseg + 1) * 2;
%             [pp, ier] = BSFK(toff, T, 2, nknots);
%             while ( any(pp.coefs(:,1) > 0) ||...
%                     any(pp.coefs(2:end,1) - pp.coefs(1:end-1,1)< 0) ) && ...
%                     nknots >= numseg 
%                 nknots = nknots-1;
%                 [pp, ier] = BSFK(toff, T, 2, nknots);
%             end
%             if any(pp.coefs(:,1) > 0)
%                 error('wrong');
%             end
%             if ier 
%                 breaks = pp.breaks(2:end);
%                 table(:,1) = breaks(:);
%                 table(:,2) = pp.coefs(:,1);
%               
% %                 fnplt(pp);hold on; plot(toff,T);
% %                 pause(0.05);
% %                 clf;
%                 
%             else
%                 error('failed');
%             end
%         else
%             table(:,1) = toff(2:end)';
%             slopes = T(2:end) - T(1:end-1);
%             table(:,2) = slopes(:);
%         end
%         
table = linearApproximate(toff, T, numseg);
        tempdata{j} = table;
    end
    
    
    LR_Data{i} = tempdata;
end


