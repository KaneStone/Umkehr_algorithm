function [N] = Nvaluezs(atmos,lambda,zs,theta,ozonexs,bandpass)
%zs represents the zenith sky paths
%Part of Radiative transfer. calculating the intensities and the N-values

sz = size(zs);
intensity = ones(length(lambda),sz(2),atmos.nlayers-1)*1e7;
intenstar = ones(length(lambda),sz(2),atmos.nlayers-1)*1e7;
rayphase = zeros(6,sz(2));
atmos.Apparent (atmos.Apparent == 0) = NaN;

%solar*bandpasses
solar  = atmos.solar(:,3);

for j = 1:length(lambda);
    solar  = atmos.solar(:,3);
    solar (atmos.solar(:,1) <= lambda(j) - bandpass(j)/2 | atmos.solar(:,1) >= lambda(j) + bandpass(j)/2) = [];
    S = conv(solar,bandpass(j));
    for iscat = 1:atmos.nlayers-1;
        rayphase = reshape(3./(4.*(1+2.*atmos.pgamma(j))).*...
        ((1+3.*atmos.pgamma(j))+(1-atmos.pgamma(j)).*((cosd(atmos.Apparent(j,iscat,:))).^2)),1,sz(2));
    
        intensity(j,:,iscat) = (intensity(j,:,iscat).*...
            (atmos.bRay(j,iscat).*rayphase))./(4.*pi);   
        
        intenstar(j,:,iscat) = (intenstar(j,:,iscat).*...
            (atmos.bRay(j,iscat).*rayphase))./(4.*pi);    
        
         for i = 1:atmos.nlayers-1;

             intensity(j,:,iscat) = intensity(j,:,iscat).*...
                 exp(-1.*(atmos.bRay(j,i)+(ozonexs(j,i)).*atmos.ozonemid(i)).*...
                 zs(j,:,iscat,i).*100);            
             
             intenstar(j,:,iscat) = intenstar(j,:,iscat).*...
                 exp(-1.*atmos.bRay(j,i).*zs(j,:,iscat,i).*100);
             
             
         end 
    end
end

intensity = permute(intensity,[1 3 2]);
intensity (isnan(intensity)) = 0;

intenstar = permute(intenstar,[1 3 2]);
intenstar (isnan(intenstar)) = 0;

for j = 1:length(lambda);
    for k = 1:sz(2)
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

