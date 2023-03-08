classdef fftH < handle
   
    properties (SetAccess = private)
        M
        mapping
        flag
        valid
        requestN
    end
    
    
    methods
        % constructor, 2-D matrix
        function obj        = fftH(length, n, requestN)
            obj.M = zeros(length, n, n,'single');
            obj.flag = false(requestN, requestN);
            obj.mapping = zeros(1, requestN); 
            obj.valid = false;
            obj.requestN = requestN;
        end
        
        function []         = fftHinit(obj, activeIdx)
             validateattributes(activeIdx, {'double','single'}, ...
                 {'>=',1,'integer', 'size', [1, size(obj.M, 2)], '<=', obj.requestN});
            obj.mapping(activeIdx) = 1 : 1 : size(obj.M, 2);
            obj.flag(activeIdx, activeIdx) = true;
            obj.valid = true;
        end
        %%
        function [Idout]         = mappingId(obj, Idin)
            if Idin <= obj.requestN && obj.valid
                Idout = obj.mapping(Idin);
            else
                Idout = 0;
            end
        end
        
        function [flag] = fftHwrite(obj, i, j, v)
            xi = mappingId(obj, i);
            xj = mappingId(obj, j);
            
            if xi * xj ~= 0
            obj.M(:, xi, xj) = v;
            flag = true;
            else
                flag = false;
               warning('invalid input id');
               i
               j
            end
        end
        
        function v = fftHread(obj, i, j)
            xi = mappingId(obj, i);
            xj = mappingId(obj, j);
            
            if xi * xj ~= 0
                 v = obj.M(:, xi, xj);
            else
                warning('invalid input id');
                i
                j
                v =0;
            end
        end
        
        function [] = fftHreset(obj)
            prop    = properties(obj);
            for k = 1 : length(prop)
                obj.(prop{k}) = [];
            end
        end
    end
    
end


