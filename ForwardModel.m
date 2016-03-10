function [K, simulatedNvalues] = ForwardModel(ozone, setup, inputs)	
%yhat Ns and K, the weighting functions are returned given x the 
%state vector. K is only calculated if Kflg is 1.
%Extras contains all other information needed that i.e. SZAs, cross
%sections, wavelengths, bandpasses and other stuff.

simulatedNvalues = Nvaluezs(ozone, setup.atmos, setup.lambda, setup.zs,...
    setup.ozonexs, inputs);
sz = size(simulatedNvalues);
yhat = reshape(simulatedNvalues', sz(1) * sz(2), 1);
yhat (isnan(yhat)) = [];

%one percent change in ozone.
if inputs.logswitch       
    pert = ozone/100;        
else
    pert = ozone/100;
end

%Calculating weighting functions

for i = 1:setup.atmos.nlayers
    clearvars xpert
    xpert = ozone;
    xpert(i) = ozone(i) + pert(i);
%             if extra.logswitch
%                xpert = exp(xpert);
%             end        
    simulatedNvalues_pert = Nvaluezs(xpert, setup.atmos, setup.lambda, setup.zs, ...
        setup.ozonexs, inputs);
    sz = size(simulatedNvalues_pert);
    ypert = reshape(simulatedNvalues_pert', sz(1) * sz(2), 1);
    ypert (isnan(ypert)) = [];
    if inputs.logswitch
        %K(:,i) = (ypert-yhat)./log(extra.pert(i));                  
        K(:,i) = (ypert-yhat)./log(xpert(i)./setup.atmos.ozone(i));                  
        %K(:,i) = ((ypert-yhat)./extra.pert(i))*x(i);                  
        %K(:,i) = (ypert-yhat)./log(extra.pert(i));
    else
        K(:,i) = (ypert-yhat)./pert(i);
    end      
    %K(:,i) = (ypert-yhat)./log(xpert(i));      
end

end