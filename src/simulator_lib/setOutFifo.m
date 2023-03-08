 
        function obj = setOutFifo(obj, fifo)
%             if ~isa(fifo, 'FIFO')
%                 error('uncorrect fifo');
%             end
            obj.outputFifo = fifo;
        end