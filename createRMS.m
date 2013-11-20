function [RMS] = createRMS(y,yhat)

a = y-yhat;
RMS = sqrt(sum(a.^2)/length(a));

end