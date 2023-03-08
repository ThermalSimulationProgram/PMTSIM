function config = getAdaptInfoBWS(obj, accuTrace, trace)
activeSet  = [];
sleepSet = [];
ccs = [];
dcs = [];
Q = [];
TBET =  (obj.tswoffs + obj.tswons)*1.1;

for i = 1 : obj.nstage
    if obj.coreArray(i).state ~= 0
        activeSet  = [activeSet, i];
    else
        sleepSet = [sleepSet, i];
        ccs = [ccs, max(0, TBET(i) - obj.coreArray(i).sleepTime )];
    end
    Q = [Q, obj.coreArray(i).inputFifo.Q];
    
end
CurTime = obj.currentTime;
alpha = obj.upperBoundsI;
stepWidth = obj.stepWidth;
buckets = obj.buckets;

eventArrivals = GetArrivalNum(accuTrace, obj.currentTime);
deadline = obj.inPort(1).deadline - obj.inPort(1).arrivalTime;
WCETs = obj.WCETs;
deltaT = obj.deltaT;
trace_org = trace;


m = obj.nstage;
for i=1 : obj.nstage
    k=min(1./WCETs(i:end));
    if(i==1)
        load = getLoad(obj.coreArray(i));
        alpha_d=historyAwareAlphaByLeakyBucket_BSW(alpha,CurTime, stepWidth, buckets, eventArrivals);
        alpha_d=rtcaffine(alpha_d,1,deadline);
        FIFO = obj.coreArray(i).inputFifo;
        FIFO.buf = [];
        for id = 1 : FIFO.Q
            FIFO.buf = [FIFO.buf; FIFO.eventArray(id).id];
        end
        EventTrace = obj.coreArray(i).eventTrace(end, 1);
        alpha_f_data=Get_FIFO_Demand(WCETs(i),FIFO,CurTime,trace_org,load, EventTrace);
        alpha_f = rtccurve(alpha_f_data);
        alpha_d=rtcplus(alpha_d,alpha_f);
        
        [flag, curvedata] = getRTCCurveData(alpha_d);
        flag = 0;
        if flag
            DCS0=minbdf_BSF_curvedata(curvedata, deadline, k);
        else
            DCS0=minbdf_BSF(alpha_d,deadline,k);
        end
        DCS0=DCS0-sum(WCETs(i:end));
        %         if DCS0 < 0
        %             error('error');
        %         end
        %         DCS0=DCS0-sum(WCETs(i:end))+max(WCETs(i:end));
        InterQ=0;
        for j=(i+1) : obj.nstage
            tempload = getLoad(obj.coreArray(j));
            if(tempload)
                InterQ=InterQ+(Q(j)+1)./min(1./WCETs(j:end));
            else
                InterQ=InterQ+Q(j)./min(1./WCETs(j:end));
            end
        end
        DCS0=DCS0-InterQ;
        %DCS(i)=DCS(i)-sum((Q((i+1):end)+1)./min(1./WCETs((i+1):end)));
        if(DCS0<0)
            DCS(m-i+1)=0;
            %error('Deadline factor is not biger enough!!!');
        else
            DCS(m-i+1)=DCS0;
        end
    else
        FIFO = obj.coreArray(i).inputFifo;
        FIFO.buf = [];
        for id = 1 : FIFO.Q
            FIFO.buf = [FIFO.buf; FIFO.eventArray(id).id];
        end
        load = getLoad(obj.coreArray(i));
        if(FIFO.Q || round(load/deltaT)>0)
            if(isempty(obj.coreArray(i).eventTrace))
                alpha_d=Get_FIFO_Demand(WCETs(i),FIFO,CurTime,trace_org, load,[]);
            else
                alpha_d=Get_FIFO_Demand(WCETs(i),FIFO,CurTime,trace_org, load, obj.coreArray(i).eventTrace(end,1));
            end
            %DCS0=minbdf_BSF_curvedata(alpha_d, deadline, k);
            alpha_d = rtccurve(alpha_d);
            DCS0=minbdf_BSW(alpha_d,deadline,k);
            DCS0=DCS0-sum(WCETs(i:end));
            %             DCS0=DCS0-sum(WCETs(i:end))+max(WCETs(i:end));
            InterQ=0;
            for j=(i+1):obj.nstage
                tempload = getLoad(obj.coreArray(j));
                if( tempload > 0)
                    InterQ=InterQ+(Q(j)+1)./min(1./WCETs(j:end));
                else
                    InterQ=InterQ+Q(j)./min(1./WCETs(j:end));
                end
            end
            DCS0=DCS0-InterQ;
            %DCS(i)=DCS(i)-sum((Q((i+1):end)+1)./min(1./WCETs((i+1):end)));
            if(DCS0<0)
                DCS(m-i+1)=0;
                %error('Deadline factor is not biger enough!!!');
            else
                DCS(m-i+1)=DCS0;
            end
        else
            DCS(m-i+1)=inf;
        end
    end
    
    
end








config.activeSet  = activeSet;
config.sleepSet = sleepSet;
config.ccs = ccs;
config.dcs = DCS;
config.Q = Q;
config.TBET = TBET;
config.currentTime = CurTime;


end
