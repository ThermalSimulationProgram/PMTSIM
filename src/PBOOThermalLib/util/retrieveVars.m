function xout = retrieveVars(xin, validid, n)
if ~isvector(xin) 
    error('validid must be a vector');
end

if max(validid) > n
    error('input indexs exceeds bound n');
end

if isvector(xin)
    xin = xin(:)';
end

if size(xin,2) ~= size(validid,2)
    xin
    ids
    n
    error('size of xin does not agree with ids');
end

if size(xin,2) > n
    error('size of xin and validid exceeds bound n');
end

if size(validid, 1) ~= 1
    error('validid must be a vector');
end

m = size(xin,1);

validid = round(validid);
xout = zeros(m, n);

xout(:,validid) = xin;
end









% 
% function xout = retrieveVars(xin, validid, n)
% if max(validid) > n
%     error('input indexs exceeds bound n');
% end
% 
% if numel(xin) > n
%     error('size of xin exceeds bound n');
% end
% 
% if numel(xin) ~= numel(validid)
%     xin
%     ids
%     n
%     error('size of xin does not agree with ids');
% end
% 
% xout = zeros(1, n);
% xout(validid) = xin;
% end