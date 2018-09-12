function PlotCorrelation(x,y,label_x,label_y)

scatter(x, y, '.')
xlabel(label_x)
ylabel(label_y)
title(sprintf('corr = %.3g', corr(x, y)))

end

