classdef pathoptiset < handle
    properties (SetAccess = private)
        mfile
        iopattern
        iofiletype
        filename
        fpath
        cwp
        owp
    end
    
    
    methods
        
        function [obj] = pathoptiset(varargin)
            
            if ~ ( nargin == 0 || nargin == 4)
                error('input arguments number should be zeros or four');
            end
            
            if nargin > 0
                obj = pathoptiset();
                
                obj.mfile       = varargin{1};
                obj.iopattern   = varargin{2};
                obj.iofiletype  = varargin{3};
                obj.filename    = varargin{4};
            end
            obj.owp = pwd;
            [~, obj.fpath] = getPath(obj);
            obj.cwp = pwd;
            
        end
        

        function set.mfile(obj, value)
            if exist(value, 'file') ~= 2
                warning('pathoptiset: mfile is expect to be a m file path, use the path of this file');
                value = mfilename('fullpath');
            end
            obj.mfile = value;
        end
        
        function set.iopattern(obj, value)
            validScopes     = {'i', 'o','I','O'};
            if ~any( validatestring(value, validScopes));
                error('pathoptiset: iopattern is expect to be ''i'', ''o'', ''I'', or ''O''');
            end
            obj.iopattern = value;
        end
        
        function set.iofiletype(obj, value)
            validScopes     = {'d', 'f','D','F'};
            if ~any( validatestring(value, validScopes));
                error('pathoptiset: iopattern is expect to be ''d'', ''f'', ''D'', or ''F''');
            end
            obj.iofiletype = value;
        end
        
        function set.filename(obj, value)
            validateattributes(value, {'char'},{'vector'})
            obj.filename = value;
        end
        
        
    end
    
end