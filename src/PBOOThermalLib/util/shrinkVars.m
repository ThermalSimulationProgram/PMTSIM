function [xout] = shrinkVars(xin, validid)

% nl = size(xin, 2); % size of input x, larger one
% ns = size(validid, 2); % size of output, smaller one
% 
% if max(validid) > nl
%     error('input indexs exceeds bound n');
% end
% 
% if ns > nl
%     error('two many ids in validid');
% end
% 
% if ns == 0  
%     error('empty  validid');
% end
% 
% if nl == 0
%     error('empty  xin');
% end
% 
% if size(validid, 1) ~= 1
%     error('validid must be a vector');
% end
% 
% if min(validid) <= 0
%      error('input ids must be positive');
% end
% 
% validid = round(validid);

xout = xin(validid);

end



% function [xout] = shrinkVars(xin, validid)
% 
% nl = numel(xin); % size of input x, larger one
% ns = numel(validid); % size of output, smaller one
% 
% if nl < max(validid) 
%     error('size of input xin too small');
% end
% 
% if min(validid) <= 0
%      error('input ids must be positive');
% end
% 
% validid = round(validid);
% xout = zeros(1, ns);
% xout(1:end) = xin(validid);
% 
% end