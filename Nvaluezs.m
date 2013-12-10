function [N] = Nvaluezs(atmos,lambda,zs,ozonexs,bandpass,mieswitch)
%zs represents the zenith sky paths
%Part of Radiative transfer. calculating the intensities and the N-values

%g is the assymetry factor and = .86 for assumed radius of .86 micrometers
g = .86;

sz = size(zs);
intensity = ones(length(lambda),sz(2),atmos.nlayers-1); %This might need to be the actual solar radiance outside atmosphere
intenstar = ones(length(lambda),sz(2),atmos.nlayers-1);
rayphase = zeros(length(lambda),sz(2));
atmos.Apparent (atmos.Apparent == 0) = NaN;

%solar*bandpasses
solar  = atmos.solar(:,1);
solar_power = atmos.solar(:,3);

%For extraterrestrial solar flux
for l = 1:length(lambda);
    solar_temp(:,l) = solar-lambda(l);
    solar_find(l) = find(abs(solar_temp(:,l)) == min(abs(solar_temp(:,l))));
    solar_at_lambda(l) = solar_power(solar_find(l))/100; %convert to W/m^2*nm
end

for j = 1:length(lambda);
%     solar  = atmos.solar(:,3);
%     solar (atmos.solar(:,1) <= lambda(j) - bandpass(j)/2 | atmos.solar(:,1) >= lambda(j) + bandpass(j)/2) = [];
%     S = conv(solar,bandpass(j));
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

% [maxa inda] = max(intensity(1,:,:));
% [maxb indb] = max(intensity(2,:,:));
% figure;
% plot(atmos.true_actual,squeeze(inda));
% hold on
% plot(atmos.true_actual,squeeze(indb),'r');
% 
% figure;
% plot(atmos.true_actual,squeeze(maxa));
% hold on
% plot(atmos.true_actual,squeeze(maxb),'r');

ratio = zeros(sz(1),sz(2));

for j = 1:length(lambda);
    %for different wavelength pair vector length functionality
    find_nan = find(~isnan(atmos.true_actual(ceil(j/2),:)));
    sz_ind = length(find_nan);
    for k = 1:sz_ind
        ratio(j,k)=sum(intensity(j,:,k)/intenstar(j,:,k));
    end
end

N=zeros(length(lambda)/2,sz(2));
wn = 1;
for k = 1:length(lambda)/2;
    N(k,:) = 100*log10(ratio(wn+1,:)./ratio(wn,:));
    wn = wn+2;
end
end

