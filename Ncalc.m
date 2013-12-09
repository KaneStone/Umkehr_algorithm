function [yhat N] = Ncalc(ozoneprofile,extra)

atmos = extra.atmos;
lambda = extra.lambda;
zs = extra.zs;
theta = extra.theta;
ozonexs = extra.ozonexs;
bandpass = extra.bandpass;
atmos.ozone = ozoneprofile;
atmos.ozonemid = interp1(atmos.Z,atmos.ozone,atmos.Zmid,'linear','extrap');

%plot(atmos.ozone,1:61);
%hold on

%intensities for direct sun and zenith sky
%[intensity.ds N.ds] = Nvalueds(atmos,lambda,ds,theta,ozonexs);
[N.zs] = Nvaluezs(atmos,lambda,zs,ozonexs,bandpass,extra.mieswitch);

sz = size(N.zs);
yhat = reshape(N.zs',sz(1)*sz(2),1);

%plotNvalues(theta,N);
end
