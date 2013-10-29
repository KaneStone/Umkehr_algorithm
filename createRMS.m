function [RMS rms1] = createRMS(y,yhat)

a = y-yhat;
RMS = rms(a);
rms1 = sum((a).^2);
end