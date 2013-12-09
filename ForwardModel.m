function [K,N]=ForwardModel(x,Kflg,AeroKflg,extra)	
%yhat Ns and K, the weighting functions are returned given x the 
%state vector. K is only calculated if Kflg is 1.
%Extras contains all other information needed that i.e. SZAs, cross
%sections, wavelengths, bandpasses and other stuff.

[yhat,N] = Ncalc(x,extra);

%extra.pert = x./100;
extra.pert = .5e11;

if (Kflg == 1)
    
    for i = 1:extra.atmos.nlayers
        clearvars xpert
        xpert = x;
        xpert(i) = x(i)+extra.pert;
        
        ypert = Ncalc(xpert,extra);
        
        K(:,i) = (ypert-yhat)./(extra.pert);
        
    end

end
    
end
