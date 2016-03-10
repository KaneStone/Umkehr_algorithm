function atmos = read_solar(atmos)

%reading in solar spectrum
% micro-watts/(cm^2*nm)
solarfilename = '../input/SolarFlux_KittPeak/M*'; %excluding hidden files

files = dir(solarfilename);
NF = length(files);
solar(:,:).s = [];

for i = 1:NF;
    fid = fopen(strcat(solarfilename(1:28),files(i,1).name));
    solar(i).s = fscanf(fid,'%f',[2,inf]);
    fclose(fid);
end

atmos.solar = horzcat(solar.s)';

end