function config = getAdaptInfo(obj, accuTrace, trace)
activeSet  = [];
sleepSet = [];
ccs = [];
dcs = [];
Q = [];
TBET = (obj.tswoffs + obj.tswons)*2;
FIFOcurveData =cell(1, obj.nstage);

workerSleepTimes=[];
workerstates = [];
for i = 1 : obj.nstage
    if obj.coreArray(i).state ~= obj.coreArray(i).sleep && ...
            obj.coreArray(i).state ~= obj.coreArray(i).swoff
        activeSet  = [activeSet, i];
        workerSleepTimes(i) = 0;
        workerstates(i) = 1;
    else
        sleepSet = [sleepSet, i];
        workerstates(i) = 0;
        workerSleepTimes(i) = obj.coreArray(i).sleepTime;
        ccs = [ccs, max(0, TBET(i) - obj.coreArray(i).sleepTime )];
    end
    % collect the numbers of events in FIFOs
    Q = [Q, obj.coreArray(i).inputFifo.Q];
    
end


CurTime     = obj.currentTime;
alpha       = obj.upperBoundsI;
stepWidth   = obj.stepWidth;
buckets     = obj.buckets;
deltaT      = obj.deltaT;

eventArrivals   = GetArrivalNum(accuTrace, obj.currentTime);
% relative deadline
deadline        = obj.inPort(1).deadline - obj.inPort(1).arrivalTime;
% wcets on every stage
WCETs           = obj.WCETs(:)';
tswons          = obj.tswons;
trace_org       = trace;
m       = obj.nstage;
rho     = zeros(1, m);
DCS     = zeros(1, m);

allLoads = zeros(1, m);

nFIFOJobs  = Q;
onGoEventIds = [];
executedlength = [];
allEventAbsDeadlines = cell(1, m);
for i = 1 : m 
    allLoads(i)  = getLoad(obj.coreArray(i));
    tempload = allLoads(i);
    if(round(tempload/deltaT)>0)
        nFIFOJobs(i) = nFIFOJobs(i) + 1;
        
        onGoEventIds(i) = obj.coreArray(i).myevent.id;
        executedlength(i) = obj.coreArray(i).myevent.executed;
        allEventAbsDeadlines{i} = obj.coreArray(i).myevent.absDeadline;
    else
        
        onGoEventIds(i) = 0;
        executedlength(i) = 0;
    end
    
    allEventAbsDeadlines{i} = [allEventAbsDeadlines{i}, ...
        getFifoEventDeadlines(obj.coreArray(i).inputFifo)];
end

% csvwrite('allnFIFOJobs.csv', nFIFOJobs(:));
% csvwrite('allexecuteds.csv', executedlength(:));
% csvwrite('allstates.csv', workerstates(:));
% csvwrite('allsleepTimes.csv', workerSleepTimes(:));
% csvwrite('allonGoEventIds.csv', onGoEventIds(:));
% csvwrite('CurTime.csv', CurTime);
for i = 1:m
    ssname = ['allEventAbsDeadlines', num2str(i), '.csv'];
%     csvwrite(ssname, allEventAbsDeadlines{i}(:));
end
config.T = obj.T(1:m);
% csvwrite('allT.csv', config.T(:));
% csvwrite('AdaptionIndex.csv', numel(obj.configs));

if  numel(obj.configs)==23
    ssss=1;
end











for i = 1 : m
    
    
    %% then get alpha_f, the arrival arrive of current load and FIFO
    % get remaining load in current stage
    FIFO        = obj.coreArray(i).inputFifo;
    FIFO.buf    = [];
    % replace with waiting events' ids
    for id = 1 : FIFO.Q
        FIFO.buf = [FIFO.buf; FIFO.eventArray(id).id];
    end
    % the latest event index
    if ~isempty(obj.coreArray(i).eventTrace)
        currentEventId  = obj.coreArray(i).eventTrace(end, 1);
    else
        currentEventId  = [];
    end
    alpha_f_data        = Get_FIFO_Demand(WCETs(i), FIFO, CurTime, trace_org,...
        allLoads(i), currentEventId);
    FIFOcurveData{i} = alpha_f_data;
    
    remained_loads = WCETs(i:end);
   % remained_loads(i) = load;
    minDSC  = sum( remained_loads );
    k = min( 1./ remained_loads );
    
    %% get the arrival curve alpha_d for stage i
    % alpha_d = u(delta - D) + alpha_f
    %% first get u(delta - D)
    if i==1
        % history aware arrive curve
        alpha_u     = historyAwareAlphaByLeakyBucket_BSW(alpha, CurTime,...
            stepWidth, buckets, eventArrivals);
        % right shift, get the demand service curve
        alpha_u     = rtcaffine(alpha_u, 1, deadline);
        
        %% get the real arrival curve
        alpha_f     = rtccurve(alpha_f_data);
        alpha_d     = rtcplus( alpha_u, alpha_f );
        
%         [flag, curvedata] = getRTCCurveData(alpha_d);
        
        flag =false;
        % check if there exists at least one event arrive
        if flag
            if all(round(curvedata(:,2),5) <= 0)
                DCS(m-i+1) = inf;
            end
             bmax    = minbdf_BSF_curvedata(curvedata, deadline, k);
        else
            curvezero   = rtccurve([0,0,0]);
            if rtceq( alpha_d, curvezero ) % no event arrives
                DCS(m-i+1) = inf;
            end
            bmax    = minbdf_BSF(alpha_d, deadline, k);
            [tau] = minbdf_BSF2(alpha_d,deadline,k);
            
            if abs(tau-bmax)>0.01
                ssss=1;
            end
        end

        % choose bmax based on given parameter
        bmax   = minDSC + obj.bcoef * (bmax - minDSC);
        % calculate the common slope for current dcs0
        if flag
            rho(i)  = minspeedbdfEDG_curvedata(curvedata, bmax, 1);
        else
            rho(i)  = minspeedbdfEDG(alpha_d, bmax, 1);
            k= minspeedbdfEDG2(alpha_d, bmax);
            if abs(k-rho(i))>0.01
                sss=1;
            end
        end
        rho(i) = min(k, rho(i));
        
    else
         if all(round(alpha_f_data(:,2),5) <= 0)
                DCS(m-i+1) = inf;
                rho(i)  = max(rho(1:i-1)); % max(rho(1:i-1))
                bmax = inf;
         else
             minrho = minspeedbdfEDG_curvedata(alpha_f_data, minDSC, 5);
             rho(i) = min(k, max(minrho, rho(i-1)));
             [bmax, taus2] = minbdf_BSF_curvedata(alpha_f_data, deadline, rho(i));
         end
    end
    

    % step 3
    InterQ  = 0;
    for j   = (i+1) : m
        tempload = allLoads(j);
        if(round(tempload/deltaT)>0)
            InterQ = InterQ + (Q(j)+1)./min(1./WCETs(j:end));
        else
            InterQ = InterQ + Q(j)./min(1./WCETs(j:end));
        end
    end
    if DCS( m - i + 1) == 0
        DCS0 = bmax - minDSC - InterQ;
        DCS( m - i + 1) = max( DCS0, 0 );
    end
    
    
end

config.activeSet  = activeSet;
config.sleepSet = sleepSet;
config.ccs = ccs;
config.dcs = DCS;
config.Q = Q;
config.TBET = TBET;
config.currentTime = CurTime;
K = rho.*WCETs;

if any(K > 1 )
    error('wrong slope');
end

K = min(1, K);
config.K = K;
config.rho = rho;
config.deltaT = deltaT;
config.tswons = obj.tswons;
config.tswoffs = obj.tswoffs;

config.offlineData = obj.offlineData;
config.wcets = WCETs;

% csvwrite('Q.csv', config.Q(:));
% csvwrite('activeSet.csv', config.activeSet(:)-1);
% csvwrite('sleepSet.csv', config.sleepSet(:)-1);
% csvwrite('ccs.csv', config.ccs(:));
% 
% tmpdcs = config.dcs(:);
% for i = 1 : numel(tmpdcs)
%     if isinf(tmpdcs(i))
%         tmpdcs(i) = 900000;
%     end
% end
% 
% csvwrite('dcs.csv', tmpdcs);
% csvwrite('rho.csv', config.rho(:));
% csvwrite('K.csv', config.K(:));
% 
% 
% for i = 1 : obj.nstage
% csvwrite(['FIFOcurveData', num2str(i),'.csv'], FIFOcurveData{i}(:));
% end





% workerinfo tmp;
% 		stringstream name1;
% 		name1 << "nFIFOJobs" << i+1 << ".csv";
% 		tmp.nFIFOJobs = (unsigned) getDouble(name1.str());
% 		name1.str("");
% 
% 		name1 << "executed" << i+1 << ".csv";
% 		tmp.executed = (double) getDouble(name1.str());
% 		name1.str("");
% 
% 		name1 << "state" << i+1 << ".csv";
% 		unsigned s = (unsigned) getDouble(name1.str());
% 		if (s==0)
% 			tmp.state = _sleep;
% 		else
% 			tmp.state = _active;
% 		name1.str("");
% 
% 		name1 << "sleepTime" << i+1 << ".csv";
% 		tmp.sleepTime = (double) getDouble(name1.str());
% 		name1.str("");
% 
% 		name1 << "onGoEventId" << i+1 << ".csv";
% 		tmp.onGoEventId = (unsigned) getDouble(name1.str());
% 		name1.str("");
% 
% 		name1 << "allEventAbsDeadlines" << i+1 << ".csv";
% 		tmp.allEventAbsDeadlines = getVector<double>(name1.str());
% 		name1.str("");
    

end


