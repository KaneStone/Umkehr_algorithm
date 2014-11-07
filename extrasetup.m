function extra = extrasetup(atmos,measurement_number,station,year)
%path for input files
inputpath = '/Users/stonek/work/Dobson/input/';
%Need to appropriately define input file locations throughout script

%Logicals and other switches
extra.logswitch = 0; %retrieve in log space (currently doesn't work)
extra.mieswitch = 1; %include Mie scattering
extra.refraction = 1; %include refraction
extra.normalise_to_LSZA = 1; %normalise measurments
extra.WLP_to_retrieve = 'C'; % define wavelength pairs to retrieve: all permutations possible.
extra.morn_or_even = 'evening'; % only invoked if both morning and evening measurements are taken on same day
extra.seasonal = 'monthly'; %'monthly', 'seasonal' or 'constant' for ozone, temperature, and pressure profiles
extra.designated_SZA = 0; %retrieve using designated SZAs (not infallable)
extra.plot_inten = 0; %plot intensity curves for selected SZAs (diagnostic code)
extra.test_model_height_limit = 0; %switch for testing model height limit on zenith paths
extra.full_covariance = 0; %produce Sa matrix using Rodgers definition
extra.L_Ozone = 1; %Retrieve ozone profile
extra.L_Aerosol = 0; %Retrieve aerosol profile (currently doesn't work, in progress)
extra.L_curve_diag = 0; %produce L_curve for Sa optimisation (does not produce regular retrieval)
extra.Lcurve_mult_fact = 0; %not a switch but starting L_curve scale factor
extra.SZA_limit = 94; %upper limit of SZA to use

%OUTPUT folders are not complete
extra.output_retrievals = '/Users/stonek/work/Dobson/OUTPUT/retrievals/';
extra.output_resolution = '/Users/stonek/work/Dobson/OUTPUT/resolution/';
extra.output_diagnostics = '/Users/stonek/work/Dobson/OUTPUT/plots/diagnostics/';

%Naming conventions
extra.name_ext = [];
ext_start = 1;
if extra.designated_SZA
    extra.name_ext(ext_start:ext_start+5) = '_desig';
    ext_start = ext_start+6;
end
if extra.full_covariance
    extra.name_ext(ext_start:ext_start+2) = '_FC';
    ext_start = ext_start+3;
end
if extra.SZA_limit ~= 94 && ~extra.designated_SZA;
    extra.name_ext(ext_start:ext_start+2) = strcat('_',num2str(extra.SZA_limit));
end
    
%choose cross section study to use - BP,BDM or S: references supplied in
%xsectreader.m
study = 'BP';

%dobson wavelength pairs - nm
wl = struct('a',[305.5,325.4],'c',[311.4,332.4],'d',[317.6,339.8]);
bandpass = [1.4,3.2,1.4,3.2,1.4,3.2]; %3.2 from Petropavlovskikh

%dobson designated SZA values
theta = [60,65,70,74,77,80,83,84,85,86.5,88,89,90];
instralt = 0; %instrument altitude

%defining layer structure
maxalt = 80000; 
atmos.dz = 1000;

atmos.Z = 0:atmos.dz:maxalt;
atmos.nlayers = length(atmos.Z);
atmos.Zmid = ((atmos.Z(2:atmos.nlayers)-atmos.Z(1:atmos.nlayers-1))/2)+...
    atmos.Z(1:atmos.nlayers-1);

%defining profile paths
profilepath.measurements = strcat(inputpath,'Umkehr/',station,'/',station,...
    '_',year,'.txt');
if strcmp(extra.seasonal,'seasonal');
    profilepath.ozone = strcat(inputpath,'station_climatology/ozone/',...
        station,'.dat');
    profilepath.Temp = strcat(inputpath,'station_climatology/temperature/'...
        ,station,'_temperature.dat');
elseif strcmp(extra.seasonal,'monthly') 
    profilepath.ozone = strcat(inputpath,'station_climatology/ozone_monthly/'...
        ,station,'.dat');
    profilepath.Temp = strcat(inputpath,'station_climatology/temperature_monthly/'...
        ,station,'_temperature.dat');
else profilepath.ozone = strcat(inputpath,'station_climatology/ozone/',...
        station,'.dat');
    profilepath.Temp = strcat(inputpath,'station_climatology/temperature/',...
        station,'_temperature.dat');
end
profilepath.Pres = strcat(inputpath,'station_climatology/Pressure/',...
    station,'_pressure.dat');
profilepath.solar = strcat(inputpath,'SolarFlux_KittPeak/M*'); %excluding hidden files
profilepath.aerosol = strcat(inputpath,'station_climatology/aerosol/AntAero10_9.dat');

%reading in profiles
atmos = profilereader(profilepath.measurements,profilepath.ozone,profilepath.Temp,...
    profilepath.Pres,profilepath.solar,profilepath.aerosol,atmos,...
    measurement_number,extra.WLP_to_retrieve,extra.morn_or_even,extra.seasonal,...
    extra.SZA_limit,extra.logswitch);

if atmos.return
    extra.no_data = 1;
    extra.next_year = 0;
    return
else extra.no_data = 0;
    extra.next_year = 0;
end
if atmos.next_year
    extra.next_year = atmos.next_year;
    return
else extra.next_year = 0;
end
if extra.normalise_to_LSZA
    atmos = normalising_measurements(atmos,extra.designated_SZA,theta,measurement_number);
end

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

%if extra.logswitch
%    ozonexs = log10(ozonexs);
%end

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