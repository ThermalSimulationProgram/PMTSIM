function [Timp, TM] = completeTimp(TM, Timp, tslp, tact,validSource, validTarget,  scalor)

p               = TM.p;
t               = 0 : p : p*( TM.sizet - 1);
tracelength     = (TM.sizet + 100) * p;
fftLength       = TM.fftLength;
if isempty(Timp)
    Timp = ImpulsePeriod2dMat(TM.n, TM.n);
end
for j = 1 : TM.n
    id_heatsource = TM.coreIdx(j);
    
    %% skip simple scenarios
    % if this node is not actived or always stays in one state, we skip
    % this node. The impulse response can be calculated directly from TM
    if ~validSource(id_heatsource) 
        continue;
    end
    %% node j is periodically switching between active and sleep
    atact   = tact(id_heatsource);
    atslp   = tslp(id_heatsource);
    powerTraced = false;
    
    for i = 1 : TM.n
        id_target = TM.coreIdx(i);
        % The peak temperature must in actived nodes, so we skip
        % non-actived nodes
        if ~validTarget(id_target)
            continue;
        end
        [flag] = ImpMatCheck(Timp, id_target, id_heatsource, atslp, atact);
        % the impulse response from j to i is already calculated and saved in Timp, skip...
        if flag
            continue;
        end
        if ~powerTraced   % if the power trace is not generated
            [origin_ptrace, periodSamplePoints, ~] = ObtainPeriodicPowerTrace(TM.ua(j),...
                TM.ui(j), atact * scalor, atslp * scalor, tracelength, TM.p);

            origin_ptrace = origin_ptrace(1:TM.sizet);
            powerTraced = true;
        end
        
        % get the interval for fft
        sampleStart     = floor( TM.tend(id_target, id_heatsource) / TM.p );
        local_maxIndex  = sampleStart + periodSamplePoints * 3;  % sampling three periods
        
        if ~TM.isComplete(id_target,id_heatsource)
            
            NH = fft( max(TM.fitResults{id_target,id_heatsource}.fitresult(t),0),fftLength) ;
            % uncomment these two lines to save NH to TM, 
			flag2 = fftHwrite(TM.fftH, id_target, id_heatsource, NH); 
            if ~flag2
                error('invalid target or heatsource!');
            end
            TM.isComplete(id_target,id_heatsource) = true;
        else
            NH = fftHread(TM.fftH, id_target, id_heatsource);
            if NH == 0
                error('invalid target or heatsource!');
            end
        end
        % do fft
        out             = ifft( NH .* fft( (origin_ptrace)', fftLength) ) * TM.p; % convolution
        out_trace       = out(sampleStart : local_maxIndex);
        clear out;
        clear NH;
        % extract one period to creat an object of class PeriodSample
        min3            = min( out_trace(end - 2*periodSamplePoints : end - periodSamplePoints) );
        min_id3         = find(out_trace(end - 2*periodSamplePoints : end - periodSamplePoints) == min3, 1);
        idx_start_time  = min_id3 + periodSamplePoints;
        
        imp             = out_trace(idx_start_time : idx_start_time + periodSamplePoints - 1);
        start_time      = (idx_start_time + sampleStart - 1) * TM.p;
        
        %% push the new impulse into Timp
        impulse         = PeriodSample();
        psPush(impulse, imp', TM.p, start_time);
        ImpMatAppendToff(Timp, id_target, id_heatsource, atslp, atact, impulse);
    end
end

end