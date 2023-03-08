function [tau] = minbdf_BSF2(beta,deadline,k)
% MINBDF Computes the maximal tau of a minimal bounded delay function for
% a given alpha curve, i.e., EQ.4 in the paper by binary search. The
% slope of the bounded delay function is always 1.
%
% [tau] = MINBDF(betaA)
%
% INPUT:
%    @beta:       the service demand curve
%    @deadline:   the relative deadline of this stream, only for bsearch
%    boundary

% OUTPUT:
%    @tau:        the  maximal tau


d=beta.segmentsLT(3000);

segLTstring = d.toMatlabString();

M = eval(segLTstring);

vectorm = M';
vectorm = vectorm(:);


segmentLength = 3;
nsegments = numel(vectorm)/segmentLength;
	
tau = deadline;
	

for i = 1 : nsegments
    segmentStartId = (i-1)*segmentLength + 1;
    x = vectorm(segmentStartId);
    y = vectorm(segmentStartId+1);
    tempslope = vectorm(segmentStartId+2);
    
    if abs(y) < 1e-7
        continue;
    end
    
    if tempslope > k
        tau = 0;
        break;
    else
        curtau = x - y/k;
    end
    
    if curtau < tau
        tau = curtau;
    end
    
    
end

	
