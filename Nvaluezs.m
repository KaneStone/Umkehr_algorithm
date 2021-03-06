function [simulatedNvalues] = Nvaluezs(ozone, atmos, lambda, bandpass, zs, ozonexs, ...
    ozonexs2, inputs, diag)
%This function simulates the intensities and N values - Part of the radaitive transfer.
%zs represents the zenith sky paths
iflog = 1;
    
%recalculate ozone_mid
ozone_mid = interp1(atmos.Z, ozone, atmos.Zmid, 'linear', 'extrap');

% g is the assymetry factor and = .86 for assumed radius of 6 micrometers
% (assumed radius has changed to .08 micrometers, so asymmetry factor will
% need to change)

g = .7;

%finding spectral wavelength intensities
for i = 1:length(lambda)
    wavelengths = (lambda(i)-bandpass(i)/2):.4:(lambda(i)+bandpass(i)/2);
    for j = 1:length(wavelengths)
        waveinten(i,j) = interp1(atmos.solar(:,1),atmos.solar(:,2),wavelengths(j));
    end
        waveintenatlength(i) = interp1(atmos.solar(:,1),atmos.solar(:,2),lambda(i));
end

waveinten (waveinten == 0) = NaN;

sz = size(zs);
intensity = ones(length(lambda),sz(2),atmos.nlayers-1);
intenstar = ones(length(lambda),sz(2),atmos.nlayers-1)*1e7;
atmos.Apparent (atmos.Apparent == 0) = NaN;
atmos.Apparent = permute(atmos.Apparent,[2 3 1]);
zs = permute(zs,[2 4 1 3]);

% Takes into account lambda width 
for iscat = 1:atmos.nlayers-1
    for j = 1:length(lambda)
        rayphase = 3./(4.*(1+2.*atmos.pgamma(j))).*((1+3.*atmos.pgamma(j))+...
            (1-atmos.pgamma(j)).*((cosd(atmos.Apparent(1:atmos.nlayers-1,:,j))).^2));       
        miephase = (1-g^2)./((1+g^2-2.*g.*...
            cosd(atmos.Apparent(1:atmos.nlayers-1,:,j))).^(3/2));
        for k = 1:size(ozonexs2(j).o,1)
            scatterfactor(j,:,k,iscat) = waveinten(j,k).*(intensity(j,:,iscat).*...
                   ((atmos.bRay(j,iscat).*rayphase(iscat,:))+...
                   ((atmos.bMie(j,iscat).*miephase(iscat,:))))./(4.*pi));                   
            intensity2(j,:,k,iscat) = squeeze(scatterfactor(j,:,k,iscat)).*exp(-1.*(atmos.bRay(j,:)+atmos.bMie(j,:)+...
                   ozonexs2(j).o(k,1:end-1).*ozone_mid(:)')*...
                   zs(:,:,j,iscat)'.*100);
        end
    end
end
    
waveinten2 = permute(repmat(waveinten,1,1,sz(2),atmos.nlayers-1),[1,3,2,4]);
 
ratio2 = nansum(reshape(intensity2,[size(intensity2,1),size(intensity2,2),size(intensity2,3)*size(intensity2,4)]),3);

intensity = permute(intensity,[1 3 2]);
intensity (isnan(intensity)) = 0;

intenstar = permute(intenstar,[1 3 2]);
intenstar (isnan(intenstar)) = 0;

%Code for testing the model top height limitations for high SZAs
if inputs.test_model_height_limit && diag
    test_model_height_limit(intensity,atmos.true_actual);
end

%To plot intensity curves
if inputs.plot_intensities && diag
    plot_inten(intensity,atmos,sz);    
end

%test the effect of small perturbations in intensity on N values.
if inputs.test_cloud_effect && diag
    cloud_effect(intensity,intenstar,atmos.true_actual,[1,3,10],'all',...
        lambda,inputs.normalise,atmos.normalisationindex);
end

simulatedNvalues = zeros(length(lambda)/2,sz(2));
wn = 1;
for k = 1:length(lambda)/2    
    %Extra Terrestrial Solar Flux (ETSF) is removed by normalising to lowest SZA
    ETSF_ratio = 1;    
    simulatedNvalues(k,:) = 100*log10(ETSF_ratio*ratio2(wn+1,:)./ratio2(wn,:));            
    
    wn = wn+2;
end

%normalising simulated N-values to lowest SZA.
if ~strcmp(inputs.normalise,'no')     
    for j = 1:length(atmos.normalisationindex)
         N_norm = simulatedNvalues(j,atmos.normalisationindex(j));         
        simulatedNvalues(j,:) = simulatedNvalues(j,:) - repmat(N_norm,1,sz(2));           
    end
end

end

