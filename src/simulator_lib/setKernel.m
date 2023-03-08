function obj = setKernel(obj, configdata)
if nargin < 2
    configdata = [];
end
if isempty(configdata)
    configdata.kernel = 'GE';
end
if ~isempty(obj.kernel)
    warning(['The kernel of the pipeline is already set! Setting kernel ',...
        'without resetting the pipeline first could cause erros or incorrect results']);
end

switch configdata.kernel
    
    case 'GE'
        %% Greedy execution kernel, all cores always stay active
        obj.kernel = obj.GE;
        adaptTime = 3*obj.deltaT;
        adaptPeriod = 5000;
        obj.adaptTime = round( adaptTime/obj.deltaT ) * obj.deltaT;
        obj.adaptPeriod = round( adaptPeriod/obj.deltaT ) * obj.deltaT;
        
            
    
    case 'PTM'
        %% Periodic Thermal Management kernel
        if isempty(obj.inPort)
            error(['Inputs should be inserted in the in port of the ',...
                'pipepline before setting PTM kernel! ']);
        end
        obj.kernel = obj.PTM;
        try
            tons = configdata.tons;
            toffs = configdata.toffs;
        catch 
            error(['The second input parameter should have fields of ''tons'' ', ...
                ' and ''toffs'' of all stages to set PTM kernel']);
        end
        if numel(tons) ~= obj.nstage || numel(toffs) ~= obj.nstage
            error(['The element numbers of ''tons'' and ''toffs'' in the ',...
                'second input parameter must equal the pipeline stage number']);
        end
        for i =1 : obj.nstage
            core = obj.coreArray(i);
            setlength = obj.inPort(end).deadline;
            setlength = max(setlength+2000, setlength*2);
            core = getPTMcTrace(core, setlength,...
                tons(i), toffs(i));
            obj.coreArray(i) = core;
        end
        obj.tons = tons;
        obj.toffs = toffs;
        obj.adaptTime = inf;
        obj.adaptPeriod = inf; 
        obj.offlineData = [];
        obj.bcoef = [];
        obj.elapsetime  = [];   
        obj.adaptcounter = [];
    case 'BWS'
        %% Balanced workload scheme kernel
        obj.kernel = obj.BWS;
        try
            adaptPeriod = configdata.adaptPeriod;
        catch 
            error(['The second input parameter should have field of ',...
                '''adaptPeriod'' ', ...
                ' to set BWS kernel']);
        end
        adaptTime = 3*obj.deltaT;
        obj.adaptTime = round( adaptTime/obj.deltaT ) * obj.deltaT;
        obj.adaptPeriod = round( adaptPeriod/obj.deltaT ) * obj.deltaT; 
        
        
        obj.elapsetime  = zeros(1, 2000);   % stores the accumulated time expense of adaption
        obj.adaptcounter = 0;               % number of adapation
        
        obj.offlineData = [];
        obj.bcoef = [];
    case 'APTM'
        %% Adaptive Periodic Thermal Management kernel
        obj.kernel = obj.APTM;
        try
            adaptPeriod = configdata.adaptPeriod;
            offlineData = configdata.offlineData;
            bcoef   = configdata.bcoef;
        catch 
            error(['The second input parameter should have fields of ',...
                '''adaptPeriod'', ''bcoef'' and ''offlineData''', ...
                ' to set APTM kernel']);
        end
        adaptTime = 3*obj.deltaT;
        [breakToffs, slopes, numValidData] = trans2matForMTtable(offlineData.mtdata);
        offlineData.breakToffs = breakToffs;
        offlineData.slopes = slopes;
        offlineData.numValidData = numValidData;
        
        
        obj.adaptTime = round( adaptTime/obj.deltaT ) * obj.deltaT;
        obj.adaptPeriod = round( adaptPeriod/obj.deltaT ) * obj.deltaT;
        obj.offlineData = offlineData;
        obj.bcoef = bcoef;
        obj.elapsetime  = zeros(1, 2000);   % stores the accumulated time expense of adaption
        obj.adaptcounter = 0;               % number of adapation
    case 'RL'
        %% Reinforce Learning Thermal Management kernel
        obj.kernel = obj.RL;
        try
            adaptPeriod = configdata.adaptPeriod;
        catch 
            error(['The second input parameter should have fields of ',...
                '''adaptPeriod''', ...
                ' to set RL kernel']);
        end
        adaptTime = 3*obj.deltaT;
        obj.adaptTime = round( adaptTime/obj.deltaT ) * obj.deltaT;
        obj.adaptPeriod = round( adaptPeriod/obj.deltaT ) * obj.deltaT;
        obj.elapsetime  = zeros(1, 2000);   % stores the accumulated time expense of adaption
        obj.adaptcounter = 0;               % number of adapation
    
    otherwise
        error('no such kernel');  
end




