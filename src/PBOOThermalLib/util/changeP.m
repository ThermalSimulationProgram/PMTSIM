function TM = changeP(TM, p)
maxt = ( TM.sizet-1 ) * TM.p;
fftL = TM.fftLength * TM.p;

TM.p = p;
TM.sizet = round( maxt/p + 1 );
TM.fftLength = round( fftL/p);

end