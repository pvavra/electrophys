function PlotPositionScatter(x,y,label_x,label_y,figureHandle)


if exist('figureHandle','var')
    figure(figureHandle)
else
    figure
end

if ~exist('label_x','var')
    label_x = 'x';
end

if ~exist('label_y','var')
    label_y = 'y';
end


subplot(221)
plot(x,y,'.')
title('scatter plot of positions')
xlabel('x-position')
ylabel('y-position')
axis xy
axis square

subplot(222)
plot(x,y,'-')
title('trajectory plot')
xlabel('x-position')
ylabel('y-position')
axis xy
axis square

subplot(2,2,[3 4])
title('timeseries of position')
plot([x y])
legend({label_x, label_y})
xlabel('time [samples]')
ylabel('position')

