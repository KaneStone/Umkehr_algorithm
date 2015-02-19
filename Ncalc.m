function [yhat N] = Ncalc(ozoneprofile,extra)

ozone = ozoneprofile;
ozonemid = interp1(extra.atmos.Z,ozone,extra.atmos.Zmid,'linear','extrap');

%diagnostic testing for midnight midday diurnal cycle.--------------------
%midday = importdata('/Users/stonek/work/Dobson/OUTPUT/midday_data.dat');
%midnight = importdata('/Users/stonek/work/Dobson/OUTPUT/midnight_data.dat');
%ozonemid = interp1(extra.atmos.Z,midday,extra.atmos.Zmid,'linear','extrap');
%ozonemid = interp1(extra.atmos.Z,midnight,extra.atmos.Zmid,'linear','extrap');
%-----------%-----------%-----------%-----------%-----------%-----------

%intensities for direct sun and zenith sky
[N.zs] = Nvaluezs(extra.atmos,ozonemid,extra.lambda,extra.zs,extra.ozonexs,...
    extra.bandpass,extra.mieswitch,extra.normalise_to_LSZA,...
    extra.plot_inten,extra.test_model_height_limit,extra.test_cloud_effect);

%ac = -ab_midday+ab;
%h = plot(extra.atmos.true_actual(1,:),ac,'LineWidth',2)

sz = size(N.zs);
yhat = reshape(N.zs',sz(1)*sz(2),1);
yhat (isnan(yhat)) = [];
end
