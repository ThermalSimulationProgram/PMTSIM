function c = newInputConfig(c)
c.inputTrace        = generateInput(c.nstage, c.stream, c.deadlinefactor, c.wcets,...
                        c.tracetype, c.tracelen, c.exefactor);
                    
end