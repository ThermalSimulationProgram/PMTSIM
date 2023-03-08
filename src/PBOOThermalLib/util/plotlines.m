function [] = plotlines(X,Y,color)
x = linspace(X(1), X(2), 100);
y = linspace(Y(1), Y(2), 100);
plot(x,y,color);
end