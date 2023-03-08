classdef CellImpulse < handle
    % A  CellImpulse object describes the impulse responses from a source node to
    % a target node, it contains:
    % toff          a vector of all the toffs 
    % ton           a vector of all the tons
    % valid         if this object is valid for use
    % id_s          the id of source node
    % id_t          the id of target node
    % impulse       a vector contains objects of class PeriodSample, each
    %               object describes one impulse response.
    properties (SetAccess = private)
        toff
        ton
        valid
        id_s
        id_t
        impulse    
    end
    
    
    methods
        % constructor, 2-D matrix
        function obj        = CellImpulse(varargin)
            obj.valid = false;
            if nargin > 0
                obj(varargin{1}, varargin{2}) = CellImpulse();
            end
            
        end
        
        function []         = ciReset(obj)
            m   = size(obj, 1);
            n   = size(obj, 2);
            for i = 1 : m
                for j = 1 : n
                    if obj(i, j ).valid
                        obj(i, j ).toff        = zeros(1,0);
                        obj(i, j ).ton         = zeros(1,0);
                        obj(i, j ).id_s        = 0;
                        obj(i, j ).id_t        = 0;
                        if ~isempty(obj(i, j ).impulse)
                             obj(i, j ).impulse(1:end)= [] ;
                        end
                        obj(i, j ).valid       = false;
                    end
                end
            end
        end
        %%
        function []         = ciInit(obj, id_t, id_s)
            if obj.valid
                error('this object has already been initialized');
            end
            obj.id_s        = id_s;
            obj.id_t        = id_t;
            obj.valid       = true;
        end
        
        function []         = ciAppendToff(obj, toff, ton, impulse)
            if ~obj.valid
                error('object not initialized');
            end
            obj.toff        = [obj.toff, toff];
            obj.ton         = [obj.ton, ton];
            obj.impulse     = [obj.impulse, impulse];
        end
        
        
        function [flag, timps]= ciFindImpulse(obj, toff, ton)
            % toff and ton have the same index!
            flag    = any( abs( obj.ton( abs(obj.toff-toff) < 1e-10 ) - ton) < 1e-10 );
            if ~flag
                timps = [];
                return
            end
                [timps] = intersect( obj.impulse(abs(obj.toff-toff) < 1e-10),...
                                     obj.impulse(abs(obj.ton-ton) < 1e-10 ));
            
        end
  
        function new = ciCopy(obj)
            m   = size(obj, 1);
            n   = size(obj, 2);
            new = CellImpulse(m, n);
            for i = 1 : m
                for j = 1 : n
                    if obj(i, j ).valid
                        prop    = properties(new(i, j));
                        for k = 1 : length(prop)
                            new(i, j).(prop{k}) = obj(i, j).(prop{k});
                        end
                    end
                end
            end
        end
        
        %%  omit for speed
%         function set.toff(obj, value)
%             validateattributes(value, {'double','single'}, {'vector','>=',0,'real'});
%             obj.toff        =  value;
%         end
%         
%         function set.ton(obj, value)
%             validateattributes(value, {'double','single'}, {'vector','>=',0,'real'});
%             obj.ton         =  value;
%         end
%         
%         function set.id_s(obj, value)
%             validateattributes(value, {'double','single'}, {'scalar','>=',0,'integer'});
%             obj.id_s        = value;
%         end
%         
%         function set.id_t(obj, value)
%             validateattributes(value, {'double','single'}, {'scalar','>=',0,'integer'});
%             obj.id_t        = value;
%         end
%         function set.impulse(obj, value)
%             validateattributes(value, {'PeriodSample'}, {'vector'});
%             obj.impulse     = value;
%         end
%         
%         function set.valid(obj, value)
%             validateattributes(value, {'logical'}, {'scalar'});
%             obj.valid       = value;
%         end
        
    end
    
end


