function [N] = Nvaluezs(atmos,lambda,zs,ozonexs,bandpass,mieswitch,norm_switch)
%zs represents the zenith sky paths
%Part of Radiative transfer. calculating the intensities and the N-values

%g is the assymetry factor and = .86 for assumed radius of 6 micrometers
g = .86;

sz = size(zs);
intensity = ones(length(lambda),sz(2),atmos.nlayers-1); %This might need to be the actual solar radiance outside atmosphere
intenstar = ones(length(lambda),sz(2),atmos.nlayers-1);
rayphase = zeros(length(lambda),sz(2));
atmos.Apparent (atmos.Apparent == 0) = NaN;

for j = 1:length(lambda);
    for iscat = 1:atmos.nlayers-1;
        rayphase = reshape(3./(4.*(1+2.*atmos.pgamma(j))).*...
        ((1+3.*atmos.pgamma(j))+(1-atmos.pgamma(j)).*((cosd(atmos.Apparent(j,iscat,:))).^2)),1,sz(2));
    
        miephase = reshape((1-g^2)./((1+g^2-2.*g.*cosd(atmos.Apparent(j,iscat,:))).^(3/2)),1,sz(2)); 
        
        if mieswitch
        intensity(j,:,iscat) = (intensity(j,:,iscat).*...
            ((atmos.bRay(j,iscat).*rayphase)+(atmos.bMie(j,iscat).*miephase)))./(4.*pi);   
        
        intenstar(j,:,iscat) = (intenstar(j,:,iscat).*...
            ((atmos.bRay(j,iscat).*rayphase)+(atmos.bMie(j,iscat).*miephase)))./(4.*pi);    
        
        else intensity(j,:,iscat) = (intensity(j,:,iscat).*...
            (atmos.bRay(j,iscat).*rayphase))./(4.*pi); %maybe put in .*solar_at_lambda here
        
        intenstar(j,:,iscat) = (intenstar(j,:,iscat).*...
            (atmos.bRay(j,iscat).*rayphase))./(4.*pi);   
        
        end
            
        
        for i = 1:atmos.nlayers-1;
%Need to put in Mie here aswell
            if mieswitch
            intensity(j,:,iscat) = intensity(j,:,iscat).*...
                exp(-1.*(atmos.bRay(j,i)+atmos.bMie(j,i)+ozonexs(j,i).*atmos.ozonemid(i)).*...
                zs(j,:,iscat,i).*100);            
            
            intenstar(j,:,iscat) = intenstar(j,:,iscat).*...
                exp(-1.*(atmos.bRay(j,i)+atmos.bMie(j,i)).*zs(j,:,iscat,i).*100);    
            
            else intensity(j,:,iscat) = intensity(j,:,iscat).*...
                exp(-1.*(atmos.bRay(j,i)+ozonexs(j,i).*atmos.ozonemid(i)).*...
                zs(j,:,iscat,i).*100);            
            
            intenstar(j,:,iscat) = intenstar(j,:,iscat).*...
                exp(-1.*atmos.bRay(j,i).*zs(j,:,iscat,i).*100);      
            end
         end 
    end
end

intensity = permute(intensity,[1 3 2]);
intensity (isnan(intensity)) = 0;

intenstar = permute(intenstar,[1 3 2]);
intenstar (isnan(intenstar)) = 0;

%Code for testing the model top height limitations for high SZAs
% [maxa inda] = max(intensity(1,:,:));
% [maxb indb] = max(intensity(2,:,:));
% figure;
% fig1 = gcf;
% set(fig1,'color','white','Position',[100 100 1000 700]);
% plot(atmos.true_actual,squeeze(inda),'o-','LineWidth',2);
% hold on
% plot(atmos.true_actual,squeeze(indb),'ro-','LineWidth',2);
% set(gca,'fontsize',18);
% xlabel('SZA','fontsize',20);
% ylabel('Altitude','fontsize',20);
% title('Atitude of maximum scattering intensity','fontsize',22);
% legend('Short wavelength','Long wavelength','location','NorthWest');
% 
% figure;
% fig2 = gcf;
% set(fig2,'color','white','Position',[100 100 1000 700]);
% plot(atmos.true_actual,squeeze(maxa),'o-','LineWidth',2);
% hold on
% plot(atmos.true_actual,squeeze(maxb),'ro-','LineWidth',2);
% set(gca,'fontsize',18);
% xlabel('SZA','fontsize',20);
% ylabel('Maximum intensity','fontsize',20);
% title('Value of maximum scattering intensity','fontsize',22);
% legend('Short wavelength','Long wavelength');

ratio = zeros(sz(1),sz(2));

for j = 1:length(lambda);
    %for different wavelength pair vector length functionality
    find_nan = find(~isnan(atmos.true_actual(ceil(j/2),:)));
    sz_ind = length(find_nan);
    for k = 1:sz_ind
        ratio(j,k)=sum(intensity(j,:,k)/intenstar(j,:,k));
    end
end

%For extraterrestrial solar flux
% for l = 1:length(lambda);
%     atmos.solar(l) = interp1(atmos.solar(:,1),lambda,atmos.solar(:,2),'linear','extrap');
% end

N=zeros(length(lambda)/2,sz(2));
wn = 1;
for k = 1:length(lambda)/2;
    ETSF = interp1(atmos.solar(:,1),atmos.solar(:,2),lambda(wn:wn+1),'linear','extrap');
    ETSF_ratio = ETSF(2)/ETSF(1);    
    %ETSF_ratio = 1;
        N(k,:) = 100*log10(ETSF_ratio*ratio(wn+1,:)./ratio(wn,:));
    %N(k,:) = 100*(log10(ratio(wn+1,:)./ratio(wn,:))-log10(ratio(wn+1,1)./ratio(wn,1)));
    wn = wn+2;
end

%normalising

if norm_switch
    [~, SZA_min_location] = min(atmos.true_actual,[],2);
    for j = 1:length(SZA_min_location);
         N_min = N(j,SZA_min_location(j));
        N(j,:) = N(j,:) - repmat(N_min,1,sz(2));   
    end
end
end

