function [ds] = Directpaths(atmos,lambda,instralt,theta)

nalt = round(instralt/atmos.dz)*atmos.dz; %calculating at instrument altitude?
iscat = find(atmos.Z==nalt);

ds = zeros(length(lambda),length(theta),atmos.nlayers); 
for i = 1:length(lambda);
    gamma = -(atmos.r/atmos.N(i,:))*(atmos.dndz(i,:)); %vector in altitude
    for j = 1:length(theta);
        Rg = atmos.Nr(i,:)*sind(theta(j)); % Rg will be a vector in altitude
        
        for l = iscat:atmos.nlayers-1
            
            a = atmos.r(l);% radius to centre of Earth (first point)
            b = a+atmos.dz;% radius to the second point 
            x1 = ((1/atmos.N(i,l))*sqrt(atmos.N(i,l)^2*a^2-Rg(l)^2)); 
            x2 = ((1/atmos.N(i,l+1))*sqrt(atmos.N(i,l+1)^2*b^2-Rg(l)^2));
            dx(l) = abs(x2-x1);
            ds1 = ((atmos.N(i,l)^2)*(a^2))/((atmos.N(i,l)^2)*(a^2)-(gamma(l)*(Rg(l)^2)));
            ds2 = ((atmos.N(i,l+1)^2)*(b^2))/((atmos.N(i,l+1)^2)*(b^2)-(gamma(l+1)*(Rg(l)^2)));
            ds(i,j,l) = dx(l)*(ds1+ds2)/2;
            %phi1 = (n(l)*Rg)/((n(l)^2)*(a(l)^2)-(gamma(l)*(Rg^2)));
            %phi2 = (n(l+1)*Rg)/((n(l+1)^2)*(b(l)^2)-(gamma(l+1)*(Rg^2)));
            %phi(l) = dx(l)*(phi1+phi2)/2;
            %chi(l) = sind(2*Rg/(nr(l)+nr(L+1)));
            
        end   %True SZA is set by the sum of PHI angles

    end
end
