function [K,N]=ForwardModel(x,Kflg,AeroKflg,extra)	
%yhat Ns and K, the weighting functions are returned given x the 
%state vector. K is only calculated if Kflg is 1.
%Extras contains all other information needed that i.e. SZAs, cross
%sections, wavelengths, bandpasses and other stuff.

[yhat,N] = Ncalc(x,extra);

%extra.pert = x./100;
%one percent change in ozone.
if extra.logswitch
    extra.pert = log10(x./100);
else extra.pert = x./100;
end

%Calculating weighting functions
if (Kflg == 1)
    for i = 1:extra.atmos.nlayers
        clearvars xpert
        xpert = x;
        xpert(i) = x(i)+extra.pert(i);
        ypert = Ncalc(xpert,extra);  
        K(:,i) = (ypert-yhat)./(extra.pert(i));      
    end
end

if (AeroKflg == 1)
    extra.aeropert = 1e-8;
    aero_x = extra.atmos.bMiept;
    for i = 1:extra.atmos.nlayers
        clearvars aeropert
        aeropert = aero_x;
        aeropert(:,i) = aero_x(:,i)+extra.aeropert;   
        extra.atmos.bMiept = aeropert;
        extra.atmos.bMie = interp1(extra.atmos.Z,extra.atmos.bMiept(:,:)',...
            extra.atmos.Zmid,'linear','extrap')';                
        ypert_aer = Ncalc(extra.atmos.ozone,extra);       
        K(:,i) = (ypert_aer - yhat)./extra.aeropert;
    end
end
