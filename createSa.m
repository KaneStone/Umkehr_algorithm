function Sa = createSa(quarter,logswitch,extra,i,mf)

folder = '/Users/stonek/work/Dobson/input/station_climatology/ozone/Standard_Deviation/';
fid = fopen(strcat(folder,'Hobart_SD.dat'));
data = fscanf(fid,'%f',[5,inf])';
SD = data(:,quarter)';
SD (SD <= 1e11) = 1e11;
if logswitch
    SD = log10(SD);
end
Sa_temp = interp1(data(:,1)',SD,extra.atmos.Z,'linear','extrap');

%For testing optimal Sa (L-curve)
if i == 1
    Sa_temp = Sa_temp*12;
else Sa_temp = Sa_temp.*mf;
end

Sa_temp = Sa_temp.^2;
Sa = diag(Sa_temp);

%Sa = diag(ones(1,81)*1e24); %2e22
%Sa (Sa <= 1e22) = 1e22;
%sigma=log10(1e11);
%Sa = diag(ones(1,61).*sigma.^2);

end

