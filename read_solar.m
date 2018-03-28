function solar = read_solar(atmos)

%reading in solar spectrum
% Watts/(m^2*nm)
solarfilename = '../input/forwardModelProfiles/solarFlux/M*'; %excluding hidden files

files = dir(solarfilename);
NF = length(files);
solar(:,:).s = [];

for i = 1:NF
    fid = fopen(strcat(solarfilename(1:end-2),files(i,1).name));
    solar(i).s = fscanf(fid,'%f',[2,inf]);
    fclose(fid);
end

solar = horzcat(solar.s)';

end