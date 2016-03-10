function atmos = refractiveindex(atmos,lambda,dz,refraction)
% This subroutine calculates the refractive indices for a certain wavelengths,
% using the given temperature and pressure profiles. The equation is obtained
% from Bucholtz, App. Optics. 34(15) 1995.
% Creates the arrays atmos.N, atmos.H (scaleheight) and atmos.dndz which are 
% then used for all subsequent path calculations.

%constants
temperature_surface = 288.15; pressure_surface = 1013.25; Rd = 287; g0 = 9.8066;

%radius of Earth
Re = 6371e3;
atmos.radius = Re + atmos.Z;

%converting lambda into micrometers for calculations
lambda = lambda/1000;

%terms used for Ns calculation
term1 = 5791817./(238.0185-(1./(lambda.^2)));
term2 = 167909./(57.362-(1./(lambda.^2)));

%Refractive index for standard air (Ns-1)*10^8) = term1+term2. 
%Ns(-1) becomes:
Ns = ((10^(-8))*(term1+term2));
atmos.Ns = Ns;

atmos.dndr = zeros(length(lambda),atmos.nlayers);

% Calculating: refraction at all levels (atmos.N), scaleheight (atmos.H),
% change in refractive index with height (atmos.d(el)ndz), change in
% refractive index per kilometer atmos.dndr and height correction for
% refraction (atmos.Nr)
if (refraction)
    atmos.N = 1 + (Ns * ((temperature_surface ./ atmos.temperature .* ...
        (atmos.pressure ./ pressure_surface))));    
    atmos.H = Rd ./ g0 .* atmos.temperature(1,:);
    atmos.dndz = (Ns * (((temperature_surface ./ atmos.temperature) .* ...
        (atmos.pressure ./ pressure_surface)) ./ atmos.H));          
    for i = 1:length(lambda);
        %The next line matches -dndr
         atmos.dndz(i,2:end) = ((1 + (atmos.Ns(i) .* (temperature_surface ./ ...
             atmos.temperature(1:end-1)) .* (atmos.pressure(1:end-1) ./ pressure_surface))) - ...
             (1 + (atmos.Ns(i) * (temperature_surface ./ atmos.temperature(2:end)) .* ...
             (atmos.pressure(2:end) ./ pressure_surface)))) ./ dz;
                        
        atmos.dndr(i,2:end) = (atmos.N(i,2:end) - atmos.N(i,1:end - 1))./...
            (atmos.radius(2:end) - atmos.radius(1:end - 1));        
        atmos.Nr(i,:) = atmos.N(i,:) .* atmos.radius;
    end   
     atmos.dndr(:,1) = -atmos.dndz(:,1);
else
    atmos.N = ones(length(lambda),length(atmos.Z));
    atmos.H = Rd / g0 * atmos.temperature;
    atmos.dndz = zeros(length(lambda),length(atmos.Z));
    atmos.dndr = zeros(length(lambda),length(atmos.Z));    
    for i = 1:length(lambda);          
        atmos.Nr(i,:) = atmos.N(i,:) .* atmos.radius;
    end    
end
end





