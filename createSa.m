function Sa = createSa(quarter,i)

folder = '/Users/stonek/work/Dobson/input/station_climatology/ozone/Standard_Deviation/';
fid = fopen(strcat(folder,'Macquarie_SD.dat'));
data = fscanf(fid,'%f',[5,inf])';
SD = data(:,quarter)';
SD (SD <= 1e11) = 1e11;
%Sa_temp = SD(1:61);
%Sa_temp = Sa_temp.^2;
%Sa = diag(Sa_temp)*1e-1; %*7e-4 for Maximum A Posterior approach.
Sa = diag(ones(1,61)*2e22); %2e22
%sigma=log10(1e11);
%Sa = diag(ones(1,61).*sigma.^2);
end

