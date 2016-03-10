function [setup,inputs,Umkehr,foldersandnames] = retrievalsetup(Umkehr,measurement_number,inputs)
%This function sets up the algorithm to perform the retrieval.

%OUTPUT folders are not complete
foldersandnames.retrievals = '../OUTPUT/retrievals/';
foldersandnames.resolution = '../OUTPUT/resolution/';
foldersandnames.diagnostics = '../OUTPUT/plots/diagnostics/';

%Naming conventions
[foldersandnames] = namingconventions(inputs, foldersandnames);

%dobson wavelength pairs - nm
bandpass = [1.4,3.2,1.4,3.2,1.4,3.2]; %3.2 from Petropavlovskikh

%dobson designated SZA values
theta = [60,65,70,74,77,80,83,84,85,86.5,88,89,90];

%defining layer structure
atmos.Z = 0:inputs.dz:inputs.maximum_altitude;
atmos.nlayers = length(atmos.Z);
atmos.Zmid = ((atmos.Z(2:atmos.nlayers) - atmos.Z(1:atmos.nlayers - 1)) / 2) + ...
    atmos.Z(1:atmos.nlayers - 1);

%reading in profiles
atmos = profilereader(atmos, Umkehr, inputs);

%defining wavelengths
lambda = defineLambda(Umkehr);

%reading in cross sections
ozonexs = xsectreader(inputs, atmos, lambda);

if inputs.normalise_measurements
    [atmos, Umkehr] = normalising_measurements(atmos,Umkehr,inputs,theta,measurement_number);
end

%reading in solar radiance profile
atmos = read_solar(atmos);

%calculates refractive index using pres and temp files.
atmos = refractiveindex(atmos,lambda,inputs.dz,inputs.refraction);

%calculates direct paths
%ds = Directpaths(atmos,lambda,instralt,theta);

%calculates zenith paths
[zs, atmos] = Zenithpaths(atmos,Umkehr,lambda,measurement_number,theta,...
    inputs.designated_SZA,inputs.dz,inputs.plot_pathlength);

% rayleigh scattering code
[~,atmos] = Rayleigh(atmos,lambda);

setup.atmos = atmos;
setup.lambda = lambda;
setup.zs = zs;
setup.theta = theta;
setup.ozonexs = ozonexs;
setup.bandpass = bandpass;

end