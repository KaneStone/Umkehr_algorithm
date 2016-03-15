function [setup,inputs,Umkehr,foldersandnames] = retrievalsetup(Umkehr,inputs)
%This function sets up the algorithm to perform the retrieval.

[foldersandnames] = namingconventions(inputs);

%dobson designated SZA values
theta = [60,65,70,74,77,80,83,84,85,86.5,88,89,90];

%defining layer structure
atmos.Z = 0:inputs.dz:inputs.maximum_altitude;
atmos.nlayers = length(atmos.Z);
atmos.Zmid = ((atmos.Z(2:atmos.nlayers) - atmos.Z(1:atmos.nlayers-1)) / 2) + ...
    atmos.Z(1:atmos.nlayers - 1);

atmos = profilereader(atmos,Umkehr,inputs);

lambda = defineLambda(Umkehr);

ozonexs = xsectreader(inputs,atmos,lambda);

[atmos,Umkehr,theta] = normalising_measurements(atmos,Umkehr,inputs,theta);

atmos = read_solar(atmos);

atmos = refractiveindex(atmos,lambda,inputs.dz,inputs.refraction);

%calculates direct paths
%ds = Directpaths(atmos,lambda,instralt,theta);

[zs, atmos] = Zenithpaths(atmos,Umkehr,lambda,inputs.dz,inputs.plot_pathlength);

[~,atmos] = Rayleigh(atmos,lambda);

setup.atmos = atmos;
setup.lambda = lambda;
setup.zs = zs;
setup.theta = theta;
setup.ozonexs = ozonexs;

end