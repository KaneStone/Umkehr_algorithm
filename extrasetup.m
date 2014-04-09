function extra = extrasetup(measurement_number,station,year)
%path for input files
inputpath = '/Users/stonek/work/Dobson/input/';

%switches
extra.logswitch = 0;
extra.mieswitch = 1;
extra.refraction = 1;
extra.normalise_to_LSZA =1;
extra.WLP_to_retrieve = 'ACD'; %all permutations possible.
extra.morn_or_even = 'evening'; % only invoked if both morning and evening measurements are taken on same day
extra.seasonal = 0; %monthly or seasonal ozone profiles
extra.designated_SZA = 0;

%choose cross section study to use - BP,BDM or S
study = 'BP';

%dobson wavelength pairs - nm
wl = struct('a',[305.5,325.4],'c',[311.4,332.4],'d',[317.6,339.8]);
bandpass = [1.4,3.2,1.4,3.2,1.4,3.2]; %3.2 from Petropavlovskikh

%dobson SZA values
theta = [60,65,70,74,77,80,83,84,85,86.5,88,89,90];
instralt = 0;

%defining layer structure
maxalt = 80000; 
atmos.dz = 1000;
atmos.Z = 0:atmos.dz:maxalt;
atmos.nlayers = length(atmos.Z);
atmos.Zmid = ((atmos.Z(2:atmos.nlayers)-atmos.Z(1:atmos.nlayers-1))/2)+atmos.Z(1:atmos.nlayers-1);

%defining profile paths
profilepath.measurements = strcat(inputpath,'Umkehr/',station,'/',station,'_',year,'.txt');
if extra.seasonal
    profilepath.ozone = strcat(inputpath,'station_climatology/ozone/',station,'.dat');
    profilepath.Temp = strcat(inputpath,'station_climatology/temperature/',station,'_temperature.dat');
else profilepath.ozone = strcat(inputpath,'station_climatology/ozone_monthly/',station,'.dat');
    profilepath.Temp = strcat(inputpath,'station_climatology/temperature_monthly/',station,'_temperature.dat');
end
profilepath.Pres = strcat(inputpath,'station_climatology/Pressure/',station,'_pressure.dat');
%profilepath.TaP = strcat(inputpath,'TP23_9Ant.dat');
profilepath.solar = strcat(inputpath,'SolarFlux_KittPeak/M*'); %excluding hidden files
profilepath.aerosol = strcat(inputpath,'station_climatology/aerosol/AntAero10_9.dat');

%reading in profiles
atmos = profilereader(profilepath.measurements,profilepath.ozone,profilepath.Temp,...
    profilepath.Pres,profilepath.solar,profilepath.aerosol,atmos,measurement_number,...
    extra.WLP_to_retrieve,extra.morn_or_even,extra.seasonal);
if isempty(atmos.N_values(measurement_number).WLP)
    extra.no_data = 1;
    extra.next_year = 0;
    return
end
if atmos.next_year
    extra.next_year = atmos.next_year;
    return
else extra.next_year = 0;
end
if extra.normalise_to_LSZA
    atmos = normalising_measurements(atmos,extra.designated_SZA,theta,measurement_number);
end

%TESTING WHETHER PRESSURE AND TEMPERATURE PROFILES ARE CAUSING ERRORS.
%IRINAS
%Testing Temperature and Pressure
%Press_temp = importdata(strcat(inputpath,'phprofil.dat'));
%atmos.P = Press_temp(1:81)';
%atmos.Pmid = exp(interp1(0:1000:80000,log(atmos.P),atmos.Zmid,'linear','extrap'));

%Temp_temp = importdata(strcat(inputpath,'temprofil.dat'));
%atmos.T = interp1(Temp_temp(:,1)*1000,Temp_temp(:,2),atmos.Z,'linear','extrap');
%atmos.Tmid = interp1(1000:1000:81000,atmos.T,atmos.Zmid,'linear','extrap');

%ROBYNS
%temp = importdata(strcat(inputpath,'not_used/','TP23_9Ant.dat'));
%atmos.P = interp1(temp(:,1),temp(:,3),atmos.Z,'linear','extrap');
%atmos.Pmid = interp1(temp(:,1),temp(:,3),atmos.Zmid,'linear','extrap');
%atmos.T = interp1(temp(:,1),temp(:,2),atmos.Z,'linear','extrap');
%atmos.Tmid = interp1(temp(:,1),temp(:,2),atmos.Zmid,'linear','extrap');

%CONSTANSTS
%atmos.T(:) = 270;
%atmos.Tmid(:) = 270;
%atmos.P = 1000;
%atmos.Pmid = 1000;

%Pres_EQUATION
%atmos.P = 1013.5*exp(-(0:80)/7.5);
%atmos.Pmid = 1013.5*exp(-(.5:79.5)/7.5);
%---------------------------------------------------------------------

%defining wavelengths
lambda = definelambda(wl,measurement_number,atmos);

%reading in solar radiance profile
atmos = read_solar(atmos,profilepath.solar,lambda);

%calculates refractive index using pres and temp files.
atmos = refractiveindex(atmos,lambda,bandpass,extra.refraction);

%calculates direct paths
%ds = Directpaths(atmos,lambda,instralt,theta);

%calculates zenith paths
[zs atmos] = Zenithpaths(atmos,lambda,measurement_number,theta,extra.designated_SZA);

%reading in cross sections
xs = xsectreader(strcat(inputpath,'ozonexs/'));

%interpolating cross sections to lambda
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
[~,atmos] = Rayleigh(atmos,lambda);

extra.atmos = atmos;
extra.lambda = lambda;
extra.zs = zs;
extra.theta = theta;
extra.ozonexs = ozonexs;
extra.bandpass = bandpass;
extra.no_data = 0;

end