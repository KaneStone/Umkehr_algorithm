function [Ray atmos] = Rayleigh(atmos, wavelength)
% Input wavelength in nm
% This subroutine calculates the Rayleigh extinction for certain wavelengths,
% using the given temperature and pressure profiles. The equation is obtained
% from Bucholtz, App. Optics. 34(15) 1995.

%converting lambda to micrometers for calculations
lambda = wavelength/1000;

%setting up array size
Ray.Bs = zeros(size(lambda));

%calculating rayleigh cross sections for standard air
a = ((lambda > 0.2)&(lambda<=0.5));
    %A = 3.01577e-28;
	A = 7.68246e-4;
	B = 3.55212;
	C = 1.35579;
	D = 0.11563;
	Ray.Bs(a) = A.*lambda(a).^(-1.*(B+C.*lambda(a)+D./lambda(a)));
    
b = (lambda>0.5);
    %A = 4.01061e-28; 
	A = 10.21675-4;
	B = 3.99668;
	C = 1.10298e-3;
	D = 2.71393e-2;
	Ray.Bs(b) = A.*lambda(b).^(-1.*(B+C.*lambda(b)+D./lambda(b)));

c = (lambda<0.2);
if any(c)>0
    error('Wavelength value outside acceptable range ie. <0.2 micrometres');
end

%calculating total rayleigh volume scattering coefficient with refraction
atmos.bRay = Ray.Bs.*(atmos.Ns+1)*((atmos.Pmid./1013.25).*(288.15./atmos.Tmid))*1e-5;
atmos.bRaypt = Ray.Bs.*(atmos.Ns+1)*((atmos.P./1013.25).*(288.15./atmos.T))*1e-5;

%calculating total rayleigh volume scattering coefficient without refraction
%atmos.bRay = Ray.Bs*((atmos.Pmid./1013.25).*(288.15./atmos.Tmid))*1e-5;%last term is converting into cm-1
%atmos.bRaypt = Ray.Bs*((atmos.P./1013.25).*(288.15./atmos.T))*1e-5;

%wavelengths for pgamma interpolation
WLGTH = [200,205,210,215,220,225,230,240,250,260,270,280,290,300,310,...
320,330,340,350,360,370,380,390,400,450,500,550,600,650,700,750,800,...
850,900,950,1000];

%each value is dependent on wavelengths given above
GAM = [2.326e-2,2.241e-2,2.156e-2,2.1e-2,2.043e-2,1.986e-2,1.93e-2,1.872e-2,1.815e-2,...
1.758e-2,1.729e-2,1.672e-2,1.643e-2,1.614e-2,1.614e-2,1.586e-2,1.557e-2,1.557e-2,...
1.528e-2,1.528e-2,1.528e-2,1.499e-2,1.499e-2,1.499e-2,1.471e-2,1.442e-2,1.442e-2,...
1.413e-2,1.413e-2,1.413e-2,1.413e-2,1.384e-2,1.384e-2,1.384e-2,1.384e-2,1.384e-2];

%gamma value for rayleigh phase function calculation
atmos.pgamma = interp1(WLGTH,GAM,lambda*1000);
end
