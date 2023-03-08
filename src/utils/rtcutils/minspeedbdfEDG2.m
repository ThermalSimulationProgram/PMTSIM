function k= minspeedbdfEDG2(beta, delay)
% MINBDF Computes the minmum speed by given the delay and demand sevice curve.
%
% k= minspeedbdfEDG(bdf, delay)
%
% INPUT:
%    @beta:        the service bound curve
%    @delay:      the delay

% OUTPUT:
%    k:           minumu speed
% author: Gang Chen     cheng@in.tum.de
d=beta.segmentsLT(3000);

segLTstring = d.toMatlabString();

M = eval(segLTstring);

vectorm = M';
vectorm = vectorm(:);


segmentLength = 3;
nsegments = numel(vectorm)/segmentLength;
	
k = 0;

for i = 1 : nsegments
    segmentStartId = (i-1)*segmentLength + 1;
    x = vectorm(segmentStartId);
    y = vectorm(segmentStartId+1);
    tempslope = vectorm(segmentStartId+2);
    
    if x > delay
        curSlope = y / (x - delay);
        curSlope = max(curSlope, tempslope);
    else
        if (y>1e-6)
            k = 1;
            break;
        else
            curSlope = tempslope;
        end
        
    end
    
    if curSlope > k
        k = curSlope;
    end
  
end




