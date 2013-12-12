function extra = extrasetup(test,station,year)
%path for input files
inputpath = '/Users/stonek/work/Dobson/input/';

%switches
extra.logswitch = 0;
extra.mieswitch = 1;
extra.refraction = 1;
extra.WLP_to_retrieve = 'ADC'; %all permutations possible.
extra.morn_or_even = 'evening'; % only invoked if both morning and evening measurements are taken on same day

%choose cross section study to use - BP,BDM or S
study = 'BDM';

%dobson wavelength pairs
wl = struct('a',[305.5,325.4],'c',[311.4,332.4],'d',[317.6,339.8]);
%wl = struct('a',[440,300],'c',[360,330],'d',[343,345]);
bandpass = [1.4,3.2,1.4,3.2,1.4,3.2]; %3.2 from Petropavlovskikh

%dobson SZA values
theta = [60,65,70,74,77,80,83,84,85,86.5,88,89,90];
instralt = 0;

%defining layer structure
maxalt = 80000; 
atmos.dz = (1000);
atmos.Z = 0:atmos.dz:maxalt;
atmos.nlayers = length(atmos.Z);
atmos.Zmid = ((atmos.Z(2:atmos.nlayers)-atmos.Z(1:atmos.nlayers-1))/2)+atmos.Z(1:atmos.nlayers-1);

%defining profile paths
profilepath.measurements = strcat(inputpath,'Umkehr/',station,'/',station,'_',year,'.txt');
profilepath.ozone = strcat(inputpath,'station_climatology/Ozone/',station,'.dat');
profilepath.Temp = strcat(inputpath,'station_climatology/Temperature/',station,'_temperature.dat');
profilepath.Pres = strcat(inputpath,'station_climatology/Pressure/',station,'_pressure.dat');
%profilepath.TaP = strcat(inputpath,'TP23_9Ant.dat');
profilepath.solar = strcat(inputpath,'SolarFlux_KittPeak/M*'); %excluding hidden files
profilepath.aerosol = strcat(inputpath,'station_climatology/aerosol/AntAero10_9.dat');

%reading in profiles
atmos = profilereader(profilepath.measurements,profilepath.ozone,profilepath.Temp,...
    profilepath.Pres,profilepath.solar,profilepath.aerosol,atmos,test,...
    extra.WLP_to_retrieve,extra.morn_or_even);

%defining wavelengths
lambda = definelambda(wl,test,atmos);

atmos = read_solar(atmos,profilepath.solar,lambda);
%calculates refractive index using pres and temp files.
atmos = refractiveindex(atmos,lambda,bandpass,extra.refraction);

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