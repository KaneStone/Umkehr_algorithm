function [] = Aero_Weighting_Functions(AeroKflg,extra)

extra.aeropert = 1e-8;

[yhat,N] = Ncalc(extra.atmos.ozone,extra);

if (AeroKflg == 1)
    
    for i = 1:extra.atmos.nlayers
        clearvars aeropert
        aeropert = extra.atmos.bMiept;
        aeropert(:,i) = extra.atmos.bMiept(:,i)+extra.aeropert;
        
        %atmos.bMiept = (500./wavelength).^-1.2*atmos.Aer;
        %atmos.bMie = (500./wavelength).^-1.2*atmos.Aermid;
        
        extra.atmos.bMiept = aeropert;
        extra.atmos.bMie(1,:) = interp1(extra.atmos.Z,extra.atmos.bMiept(1,:),extra.atmos.Zmid,'linear','extrap');  
        extra.atmos.bMie(2,:) = interp1(extra.atmos.Z,extra.atmos.bMiept(2,:),extra.atmos.Zmid,'linear','extrap');       
        
        %extra.atmos = Rayleigh(atmos,lambda);     
        
        ypert_aer = Ncalc(extra.atmos.ozone,extra);
        
        K_aer(:,i) = (ypert_aer - yhat)./extra.aeropert;
    end
end 
%PLOTTING
figure;
fig = gcf; 

sz = size(extra.atmos.Apparent);

set(fig,'color','white','Position',[100 100 1000 700]);

if sz(1) == 6;
    i = 3;
elseif sz(1) == 4;
    i = 2;
elseif sz(1) == 2;
    i = 1;
end

subplot(1,i,i/i);
plot(K_aer(1:sz(3),:),1:extra.atmos.nlayers);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('A pair','fontsize',20);
%axis([-1e-3 5e-3 0 60]);
if sz(1) == 2
    return
end
subplot(1,i,i/i+1);
plot(K_aer(sz(3)+1:2*sz(3),:),1:extra.atmos.nlayers);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('C pair','fontsize',20);
%axis([-.5e-3 2.5e-3 0 60]);
if sz(1) == 4;
    return
end
subplot(1,i,i/i+2);
plot(K_aer(2*sz(3)+1:end,:),1:extra.atmos.nlayers);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('D pair','fontsize',20);
%axis([-.2e-3 1e-3 0 60]);
end