function [intensity N] = Nvalueds(atmos,lambda,ds,theta,ozonexs)
%ds represents the direct sun paths (test)
%Part of Radiative transfer. calculating the intensities and the N-values

intensity = ones(length(lambda),length(theta));
intenstar = ones(length(lambda),length(theta));

for i = 1:atmos.nlayers-1;
    for j = 1:length(lambda);
        intensity(j,:) = intensity(j,:).*exp(-1*(atmos.bRay(j,i)+ozonexs(j,i)*atmos.ozonemid(i))*ds(j,:,i)*100);
        intenstar(j,:) = intenstar(j,:).*exp(-1*atmos.bRay(j,i)*ds(j,:,i)*100);
    end
end

N=zeros(length(lambda)/2,length(theta));

wn = 1;
for k = 1:length(lambda)/2;
    N(k,:) = 100*log(intensity(wn+1,:)./intensity(wn,:));
    wn = wn+2;
end

end

