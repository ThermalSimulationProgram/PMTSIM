classdef PeriodSample < handle
    % a class to describe one period sample of periodic functions
    % imp           a vector of the sample
    % p             the time resolution
    % tStart        the start time of the sample
    % tPeak         the peak time of the sample
    % tEnd          the end time of the sample
    % vMin          the min value of the sample
    % vMax          the max value of the sample
    properties (SetAccess = private)
        imp
        p
        tStart
        tPeak
        tEnd
        vMin
        vMax
        idPeak
    end
    
    methods
        function obj  = PeriodSample(varargin)
            if nargin > 0
                obj(varargin{1}, varargin{2}) = PeriodSample();
            end
        end
        function psReset(obj)
            prop    = properties(obj);
            obj.imp = zeros(1, 0);
            for i = 2 : length(prop)
                obj.(prop{i}) = 0;
            end
        end
        % only imp, p, tStart are required
        function psPush(obj, imp, p, tStart)
            %'Expected input object to be a saclar'
            obj.imp     = imp;
            obj.p       = p;
            obj.tStart  = tStart;
            obj.vMin    = min(imp);
            obj.vMax    = max(imp);
            obj.tPeak   = tStart + p * ( find(imp == obj.vMax, 1) - 1);
            obj.idPeak  = find(imp == obj.vMax,1);
            obj.tEnd    = tStart + p * ( length(imp) - 1 );
        end
        
        function psSetZero(obj, p)
            obj.imp     = zeros(1,3);
            obj.p       = p;
            obj.tStart  = p;
            obj.tPeak   = obj.tStart + p;
            obj.tEnd    = obj.tPeak + p;
            obj.vMin    = 0;
            obj.vMax    = 0;
            obj.idPeak  = 0;
        end
        
        function psCopy(obj1, obj2)
            prop    = properties(obj1);
            for i = 1 : length(prop)
                obj2.(prop{i}) = obj1.(prop{i});
            end
        end 
    end
    
end