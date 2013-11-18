function extra = extrasetup(test)
%path for input files
inputpath = '/Users/stonek/work/Dobson/input/';

%logswitch
extra.logswitch = 0;

%choose cross section study to use - BP,BDM or S
study = 'BDM';

refraction=1; %turns refraction on and off.
%dobson wavelength pairs
wl = struct('a',[305.5,325.4],'c',[311.4,332.4],'d',[317.6,339.8]);
%wl = struct('a',[440,300],'c',[360,330],'d',[343,345]);
%lambda = [wl.a(1);wl.a(2);wl.c(1);wl.c(2);wl.d(1);wl.d(2)];
bandpass = [1.4,3.2,1.4,3.2,1.4,3.2]; %3.2 from Petropavlovskikh

%dobson SZA values
theta = [60,65,70,74,77,80,83,84,85,86.5,88,89,90];
instralt = 0;

%defining layer structure
maxalt = 60000; 
atmos.dz = (1000);
atmos.Z = 0:atmos.dz:maxalt;
atmos.nlayers = length(atmos.Z);
atmos.Zmid = ((atmos.Z(2:atmos.nlayers)-atmos.Z(1:atmos.nlayers-1))/2)+atmos.Z(1:atmos.nlayers-1);

%defining profile paths
profilepath.Rvalue = strcat(inputpath,'Umkehr/','Hobart/', 'Hobart_1982.txt');
%profilepath.Rvalue = strcat(inputpath,'Umkehr/','Melbourne/', 'Melbourne_1994.txt');
profilepath.ozone = strcat(inputpath,'station_climatology/Ozone/','Hobart.dat');
profilepath.Temp = strcat(inputpath,'station_climatology/Temperature/','Hobart_temperature.dat');
profilepath.Pres = strcat(inputpath,'station_climatology/Pressure/','Hobart_pressure.dat');
%profilepath.TaP = strcat(inputpath,'TP23_9Ant.dat');
profilepath.solar = strcat(inputpath,'SolarFlux_KittPeak/l*'); %excluding hidden files

%reading in profiles
atmos = profilereader(profilepath.Rvalue,profilepath.ozone,profilepath.Temp,profilepath.Pres,profilepath.solar,atmos,test);

if strcmp(atmos.N_values(test).WLP(1),'A')
    lambda = [wl.a(1);wl.a(2);wl.c(1);wl.c(2);wl.d(1);wl.d(2)];    
elseif strcmp(atmos.N_values(test).WLP(1),'C') 
    lambda = [wl.c(1);wl.c(2)];
end

%calculates refractive index using pres and temp files.
atmos = refractiveindex(atmos,lambda,bandpass,refraction);
%ds = Directpaths(atmos,lambda,instralt,theta);
[zs atmos] = Zenithpaths(atmos,lambda,test);

%reading in cross sections
xs = xsectreader(strcat(inputpath,'ozonexs/'));

if strcmp(study,'BP')
    temphold = interp1(xs.BPtemp,xs.BPsigma,atmos.T,'linear','extrap'); 
    ozonexs = interp1(xs.BPwl,temphold',lambda,'linear','extrap');    
elseif strcmp(study,'BDM')
    temphold = interp1(xs.BDMtemp,xs.BDMsigma,atmos.T,'linear','extrap'); 
    ozonexs = interp1(xs.BDMwl,temphold',lambda,'linear','extrap');  
elseif strcmp(study,'S')
    temphold = interp1(xs.Stemp,xs.Ssigma,atmos.T,'linear','extrap'); 
    ozonexs = interp1(xs.Swl,temphold',lambda,'linear','extrap');  
end

% rayleigh scattering code
[ray atmos] = Rayleigh(atmos,lambda);

extra.atmos = atmos;
extra.lambda = lambda;
extra.zs = zs;
extra.theta = theta;
extra.ozonexs = ozonexs;
extra.bandpass = bandpass;

end