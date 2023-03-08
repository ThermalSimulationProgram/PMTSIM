classdef flpNode < handle
    % floorplan node class.
    % width         width of the node
    % height        height of the node
    % x             the coordinate of left down corner
    % y             the coordinate of left down corner
    % left          the id of the node besides left this node
    % right         the id of the node besides right this node
    % upper         the id of the node besides upper this node
    % below         the id of the node besides below this node
    % id            the id of this node
    % name          the name of this node
    % center        the coordinate of the center of this node
    % neighbs       this node's neighbors
    properties (SetAccess = private)
        width
        height
        x
        y
        left
        right
        upper
        below
        id
        name
    end
    
    properties (Dependent)
        center
        neighbs
    end
    
    methods
        % 2D constructor
        function obj = flpNode(varargin)
            if nargin > 0
                obj(varargin{1}, varargin{2}) = flpNode();
            end
        end
        
        function fnSet(obj, w, h, x, y, id, name)
            obj.width   = w;
            obj.height  = h;
            obj.x       = x;
            obj.y       = y;
            obj.id      = id;
            obj.name    = name;
        end
        % we assume obj1 and obj2 have same width and height
        function fnTestNeighb(obj1, obj2)
            if abs( obj1.center(1) - obj2.center(1) - (obj1.width + obj2.width) * 0.5) <= 1e-10 &&...
                    abs( obj1.center(2) - obj2.center(2)) <= 1e-10
                obj1.left = obj2.id;
            else if abs( obj2.center(1) - obj1.center(1) - (obj1.width + obj2.width) * 0.5) <= 1e-10 &&...
                        abs( obj1.center(2) - obj2.center(2)) <= 1e-10
                    obj1.right = obj2.id;
                else if abs( obj2.center(2) - obj1.center(2) - (obj1.height + obj2.height) * 0.5) <= 1e-10 &&...
                            abs( obj1.center(1) - obj2.center(1)) <= 1e-10
                        obj1.upper = obj2.id;
                    else if abs( obj1.center(2) - obj2.center(2) - (obj1.height + obj2.height) * 0.5) <= 1e-10 &&...
                                abs( obj1.center(1) - obj2.center(1)) <= 1e-10
                            obj1.below = obj2.id;
                        end
                    end
                end
            end
        end
        
        function dist = fnGetDist(obj1, obj2)
            if nargin < 2
                error('not enough input');
            end
                dist = ( (obj1.center(1) - obj2.center(1))^2 +...
                    (obj1.center(2) - obj2.center(2))^2  )^0.5; 
        end
        
        function value = get.center(obj)
            cx = obj.x + obj.width / 2;
            cy = obj.y + obj.height / 2;
            value = [cx,cy];
        end
        
        function value = get.neighbs(obj)
            value = [obj.left, obj.right, obj.upper, obj.below]; 
        end
    end
end
















