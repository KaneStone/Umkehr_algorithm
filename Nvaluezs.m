function [simulatedNvalues] = Nvaluezs(ozone, atmos, lambda, zs, ozonexs, inputs)

%mieswitch,...
%    norm_switch, plot_int,test_model_height,test_cloud_effect)

%zs represents the zenith sky paths
%Part of Radiative transfer. calculating the intensities and the N-values
   
%recalculate ozone_mid
ozone_mid = interp1(atmos.Z, ozone, atmos.Zmid, 'linear', 'extrap');

%g is the assymetry factor and = .86 for assumed radius of 6 micrometers
g = .86;

sz = size(zs);
intensity = ones(length(lambda),sz(2),atmos.nlayers-1)*1e7;
intenstar = ones(length(lambda),sz(2),atmos.nlayers-1)*1e7;
atmos.Apparent (atmos.Apparent == 0) = NaN;
atmos.Apparent = permute(atmos.Apparent,[2 3 1]);
zs = permute(zs,[2 4 1 3]);

for j = 1:length(lambda);
    rayphase = 3./(4.*(1+2.*atmos.pgamma(j))).*((1+3.*atmos.pgamma(j))+...
        (1-atmos.pgamma(j)).*((cosd(atmos.Apparent(1:atmos.nlayers-1,:,j))).^2));       
    miephase = (1-g^2)./((1+g^2-2.*g.*...
        cosd(atmos.Apparent(1:atmos.nlayers-1,:,j))).^(3/2));
    for iscat = 1:atmos.nlayers-1;        
        
        if inputs.mieswitch                  
        intensity(j,:,iscat) = (intensity(j,:,iscat).*...
            ((atmos.bRay(j,iscat).*rayphase(iscat,:))+...
            ((atmos.bMie(j,iscat).*miephase(iscat,:))))./(4.*pi))...
            .*exp(-1.*(atmos.bRay(j,:)+atmos.bMie(j,:)+...
            ozonexs(j,1:end-1).*ozone_mid(:)')*...
            zs(:,:,j,iscat)'.*100); 
        
        intenstar(j,:,iscat) = (intenstar(j,:,iscat).*...
            ((atmos.bRay(j,iscat).*rayphase(iscat,:))+...
            (atmos.bMie(j,iscat).*miephase(iscat,:)))./(4.*pi))...
            .*exp(-1.*(atmos.bRay(j,:)+atmos.bMie(j,:))*...
            zs(:,:,j,iscat)'.*100);    
        
        else intensity(j,:,iscat) = intensity(j,:,iscat).*...
            (atmos.bRay(j,iscat).*rayphase(iscat,:)./(4.*pi))...
            .*exp(-1.*(atmos.bRay(j,:)+...
            ozonexs(j,1:end-1).*ozone_mid(:)')*...
            zs(:,:,j,iscat)'.*100);
        
        intenstar(j,:,iscat) = intenstar(j,:,iscat).*...
            (atmos.bRay(j,iscat).*rayphase(iscat,:)./(4.*pi))...
            .*exp(-1.*(atmos.bRay(j,:)+atmos.bMie(j,:))*...
            zs(:,:,j,iscat)'.*100);    
        
        end          
    end
end

intensity = permute(intensity,[1 3 2]);
intensity (isnan(intensity)) = 0;

intenstar = permute(intenstar,[1 3 2]);
intenstar (isnan(intenstar)) = 0;

%Code for testing the model top height limitations for high SZAs
if inputs.test_model_height_limit
    [maxa, inda] = max(intensity(1,:,:));
    [maxb, indb] = max(intensity(2,:,:));
    figure;
    fig1 = gcf;
    set(fig1,'color','white','Position',[100 100 1000 700]);
    plot(atmos.true_actual,squeeze(inda),'o-','LineWidth',2);
    hold on
    plot(atmos.true_actual,squeeze(indb),'ro-','LineWidth',2);
    set(gca,'fontsize',18);
    xlabel('SZA','fontsize',20);
    ylabel('Altitude','fontsize',20);
    title('Atitude of maximum scattering intensity','fontsize',22);
    legend('Short wavelength','Long wavelength','location','NorthWest');

    figure;
    fig2 = gcf;
    set(fig2,'color','white','Position',[100 100 1000 700]);
    plot(atmos.true_actual,squeeze(maxa),'o-','LineWidth',2);
    hold on
    plot(atmos.true_actual,squeeze(maxb),'ro-','LineWidth',2);
    set(gca,'fontsize',18);
    xlabel('SZA','fontsize',20);
    ylabel('Maximum intensity','fontsize',20);
    title('Value of maximum scattering intensity','fontsize',22);
    legend('Short wavelength','Long wavelength');
    pause
    close fig1 fig2
end

ratio = zeros(sz(1),sz(2));

%To plot intensity curves
if inputs.plot_intensities
    plot_inten(intensity, atmos, sz);
    pause;
end

if inputs.test_cloud_effect;
    cloud_effect(intensity, intenstar, atmos.true_actual, [1,3,10], 'all',...
        lambda, 0, inputs.normalise_measurements);
end

for j = 1:length(lambda);
    %for different wavelength pair vector length functionality
    find_nan = find(~isnan(atmos.true_actual(ceil(j/2),:)));
    sz_ind = length(find_nan);
    for k = find_nan%1:sz_ind
        ratio(j,k)=sum(intensity(j,:,k).*intenstar(j,:,k))...
            ./sum(intenstar(j,:,k));
    end
end

simulatedNvalues = zeros(length(lambda)/2,sz(2));
wn = 1;
for k = 1:length(lambda)/2;
    ETSF = interp1(atmos.solar(:,1),atmos.solar(:,2),...
        lambda(wn:wn+1),'linear','extrap');  
    ETSF_ratio = 1; %ETFS is removed by normalising to lowest SZA
    simulatedNvalues(k,:) = 100*log10(ETSF_ratio*ratio(wn+1,:)./ratio(wn,:));    
    wn = wn+2;
end

%normalising simulated N-values to lowest SZA.
if inputs.normalise_measurements
    [~, SZA_min_location] = min(atmos.true_actual,[],2);
    for j = 1:length(SZA_min_location);
         N_norm = simulatedNvalues(j,atmos.normalisationindex(j));
        simulatedNvalues(j,:) = simulatedNvalues(j,:) - repmat(N_norm,1,sz(2));   
    end
end

end

