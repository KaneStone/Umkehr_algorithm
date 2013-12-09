function Sa = createSa(quarter,logswitch)

folder = '/Users/stonek/work/Dobson/input/station_climatology/ozone/Standard_Deviation/';
fid = fopen(strcat(folder,'Hobart_SD.dat'));
data = fscanf(fid,'%f',[5,inf])';
SD = data(:,quarter)';
SD (SD <= 1e11) = 1e11;
if logswitch
    SD = log10(SD);
end
Sa_temp = SD(1:61)*10;

%For testing optimal Sa (L-curve)
%if i == 1
    %Sa_temp = SD(1:61).*10;
%else Sa_temp = SD(1:61).*mf;
%end

Sa_temp = Sa_temp.^2;
%Sa = diag(Sa_temp);

Sa = diag(ones(1,61)*5e23); %2e22
Sa (Sa <= 1e22) = 1e22;
%sigma=log10(1e11);
%Sa = diag(ones(1,61).*sigma.^2);

end

