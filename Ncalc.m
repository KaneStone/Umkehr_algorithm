function [yhat N] = Ncalc(ozoneprofile,extra)

ozone = ozoneprofile;
ozonemid = interp1(extra.atmos.Z,ozone,extra.atmos.Zmid,'linear','extrap');

%intensities for direct sun and zenith sky
[N.zs] = Nvaluezs(extra.atmos,ozonemid,extra.lambda,extra.zs,extra.ozonexs,...
    extra.bandpass,extra.mieswitch,extra.normalise_to_LSZA,...
    extra.plot_inten,extra.test_model_height_limit);

sz = size(N.zs);
yhat = reshape(N.zs',sz(1)*sz(2),1);
yhat (isnan(yhat)) = [];
end
