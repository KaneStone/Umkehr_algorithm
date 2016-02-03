function [K,N]=ForwardModel(x,Kflg,AeroKflg,extra)	
%yhat Ns and K, the weighting functions are returned given x the 
%state vector. K is only calculated if Kflg is 1.
%Extras contains all other information needed that i.e. SZAs, cross
%sections, wavelengths, bandpasses and other stuff.

[yhat,N] = Ncalc(x,extra);

%one percent change in ozone.
  if extra.logswitch       
      %extra.pert = log(x./100);
        %x = log(x);
        %extra.pert = log(x)./100;
        extra.pert = x./100;
        
  else
    extra.pert = x./100;
  end

%Calculating weighting functions
if (Kflg == 1)
    for i = 1:extra.atmos.nlayers
        clearvars xpert
        xpert = x;
        xpert(i) = x(i)+extra.pert(i);
%             if extra.logswitch
%                xpert = exp(xpert);
%             end
        ypert = Ncalc(xpert,extra);  
        if extra.logswitch
            %K(:,i) = (ypert-yhat)./log(extra.pert(i));                  
            K(:,i) = (ypert-yhat)./log(xpert(i)./x(i));                  
            %K(:,i) = ((ypert-yhat)./extra.pert(i))*x(i);                  
            %K(:,i) = (ypert-yhat)./log(extra.pert(i));
        else
            K(:,i) = (ypert-yhat)./extra.pert(i);
        end      
        %K(:,i) = (ypert-yhat)./log(xpert(i));      
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
