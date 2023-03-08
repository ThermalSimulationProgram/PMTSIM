classdef ImpulsePeriod2dMat < handle
    % A matrix describing the impulse response between floorplan nodes
    properties (SetAccess = private)
        M
    end
    
    methods
        % a m*n matrix
        function obj = ImpulsePeriod2dMat(m, n)
            obj.M = CellImpulse(m, n);
        end
        
        function ImpMatReset(obj)
            ciReset(obj.M);
        end
        
        function [flag] = ImpMatCheck(obj, i, j, toff, ton)
            if ~obj.M(i,j).valid
                flag = 0;
                return;
            end
            flag    = any( abs( obj.M(i,j).ton( abs( obj.M(i,j).toff - toff) < 1e-10 ) - ton) < 1e-10 );
        end
        
        function [flag, timps] = ImpMatFindImpulse(obj, i, j, toff, ton)
            [flag, timps] = ciFindImpulse(obj.M(i,j), toff, ton);
        end
        function ImpMatAppendToff(obj, i, j, toff, ton, impulse)
            if ~obj.M(i,j).valid 
                ciInit(obj.M(i,j), i, j)
            end
            ciAppendToff(obj.M(i,j), toff, ton, impulse);
        end
        
        function new = ImpMatCopy(obj)
            m = size( obj.M, 1);
            n = size( obj.M, 2);
            new = ImpulsePeriod2dMat( m, n );
            for i = 1 : m
                for j = 1 : n
                    new.M(i, j) = ciCopy( obj.M(i, j) );
                end
            end
            
        end
        
    end
end