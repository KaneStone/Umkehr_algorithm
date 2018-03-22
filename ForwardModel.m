function [K, simulatedNvalues] = ForwardModel(ozone, setup, inputs, diag)	
%yhat Ns and K, the weighting functions are returned given x the 
%state vector. K is only calculated if Kflg is 1.
%Extras contains all other information needed that i.e. SZAs, cross
%sections, wavelengths, bandpasses and other stuff.

simulatedNvalues = Nvaluezs(ozone, setup.atmos, setup.lambda, setup.bandpass, setup.zs,...
    setup.ozonexs, setup.ozonexs2, inputs, diag);
diag = 0;
sz = size(simulatedNvalues);
yhat = reshape(simulatedNvalues',sz(1) * sz(2),1);
yhat (isnan(yhat)) = [];

%one percent change in ozone.
pert = ozone/100;
for i = 1:setup.atmos.nlayers
    clearvars xpert
    xpert = ozone;
    xpert(i) = ozone(i) + pert(i);

    simulatedNvalues_pert = Nvaluezs(xpert, setup.atmos, setup.lambda, setup.bandpass, setup.zs, ...
        setup.ozonexs, setup.ozonexs2, inputs,diag);

    sz = size(simulatedNvalues_pert);
    
    ypert = reshape(simulatedNvalues_pert',sz(1) * sz(2),1);
    ypert (isnan(ypert)) = [];
    K(:,i) = (ypert-yhat)./pert(i);
end

%plotWfunc(K,setup.atmos.Apparent);

end