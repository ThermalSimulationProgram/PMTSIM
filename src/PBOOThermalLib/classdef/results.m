classdef results < handle

    properties (SetAccess = private)
        optb
        optrho
        miniTpeak
        solution
        kernel
        activeNum
        exetime
    end
    
    
    methods
        % constructor, 2-D matrix
        function obj        = results(varargin)
            if nargin == 7
                checkRho        = @(x) validateattributes(x, {'double', 'single'}, {'scalar', 'positive', '<', 1});
                checkb          = @(x) validateattributes(x, {'double', 'single'}, {'scalar', 'positive'});
                checksolution          = @(x) validateattributes(x, {'double', 'single'}, {'nonnegative'});
                checkid         = @(x) validateattributes(x, {'double', 'single'}, ...
                                    {'scalar', 'nonnegative', 'integer', '<=', 3});
                checknum      	= @(x) validateattributes(x, {'double', 'single'}, ...
                                    {'scalar', 'nonnegative', 'integer', '<=', 48});
                pp              = inputParser;
                addRequired(pp, 'optb', checkb);
                addRequired(pp, 'optrho', checkRho);
                addRequired(pp, 'miniTpeak', checkb);
                addRequired(pp, 'solution', checksolution);
                addRequired(pp, 'kernel',  @(x)checkid(x));
                addRequired(pp, 'activeNum', @(x)checknum(x) );
                addRequired(pp, 'exetime', checkb);

                pp.KeepUnmatched = true;
                parse(pp, varargin{:});
                
                obj.optrho          = pp.Results.optrho;
                obj.optb          	= pp.Results.optb;
                obj.miniTpeak       = pp.Results.miniTpeak;
                obj.solution    	= pp.Results.solution;
                obj.activeNum    	= pp.Results.activeNum;
                obj.kernel          = pp.Results.kernel;
                obj.exetime      	= pp.Results.exetime;

            end
        end
        
        function []         = resultsMerge(obj1, obj2)
            prop    = properties(obj1);
            for k = 1 : length(prop)
                if strcmp( prop{k}, 'solution')
                    n1 = size(obj1.(prop{k}), 2);
                    n2 = size(obj2.(prop{k}), 2);
                    if n1 < n2 && n1 > 0 
                        m = size(obj1.(prop{k}), 1);
                        obj1.(prop{k})(m, n2) = 0;
                    end
                    if n1 > n2 && n2 > 0
                        m = size(obj2.(prop{k}), 1);
                        obj2.(prop{k})(m, n1) = 0;
                    end
                    obj1.(prop{k}) = [obj1.(prop{k}); obj2.(prop{k})];
                else
                    obj1.(prop{k}) = [obj1.(prop{k}), obj2.(prop{k})];
                end
            end
        end
        
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = feval(class(this));
 
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                new.(p{i}) = this.(p{i});
            end
        end
        
        function [] = setsolution(this, solution)
            this.solution = solution;
        end

        
        %%
        
       
     
        
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


