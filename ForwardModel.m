function [yhat,K,N]=ForwardModel(x,Kflg,extra)	
%yhat Ns and K, the weighting functions are returned given x the 
%state vector. K is only calculated if Kflg is 1.
%Extras contains all other information needed that i.e. SZAs, cross
%sections, wavelengths, bandpasses and other stuff.

%Call a function that calculates the N given the profile
%vector x (in Extras is everything needed, i.e. Nlayers, CrossSection
%etc...

[yhat,N] = Ncalc(x,extra);

if (Kflg == 1) %then calculate Weighting functions
    %Calculated by perturbing each layer in the profile... then taking the
    %difference
    
    for i = 1:extra.atmos.nlayers
        %pert is some perturbation to the profile (set up initially as a
        %percent of the profile
        %Each layer of the profile vector is perturbed...
        clearvars xpert
        xpert = x;
        xpert(i) = x(i)+extra.pert;
        
        ypert = Ncalc(xpert,extra);
        
        % the Weighting function matrix is then the difference in the
        % calculated Ns per unit change in the profile
        
        %K(:,i) = (ypert-yhat)./log(extra.pert);
        K(:,i) = (ypert-yhat)./(extra.pert);
        
        %K1(:,i) = (((ypert-yhat)./extra.pert)-((ypert-yhat)./15))*x(i);
    end

end
end
