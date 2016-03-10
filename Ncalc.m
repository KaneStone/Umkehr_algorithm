function [yhat, N] = Ncalc(setup, inputs)

%diagnostic testing for midnight midday diurnal cycle.--------------------
%midday = importdata('/Users/stonek/work/Dobson/OUTPUT/midday_data.dat');
%midnight = importdata('/Users/stonek/work/Dobson/OUTPUT/midnight_data.dat');
%ozonemid = interp1(setup.atmos.Z,midday,setup.atmos.Zmid,'linear','setupp');
%ozonemid = interp1(setup.atmos.Z,midnight,setup.atmos.Zmid,'linear','setupp');
%-----------%-----------%-----------%-----------%-----------%-----------

%intensities for direct sun and zenith sky
[N.zs] = Nvaluezs(setup.atmos, setup.lambda, setup.zs, setup.ozonexs, inputs);

%ac = -ab_midday+ab;
%h = plot(setup.atmos.true_actual(1,:),ac,'LineWidth',2)

sz = size(N.zs);
yhat = reshape(N.zs',sz(1) * sz(2),1);
yhat (isnan(yhat)) = [];
end
