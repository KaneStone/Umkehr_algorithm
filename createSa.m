function Sa = createSa(quarter,date_to_use,seasonal,logswitch,extra,i,mf,L_curve_diag,station)

if seasonal
    folder = '/Users/stonek/work/Dobson/input/station_climatology/ozone/Standard_Deviation/';
    fid = fopen(strcat(folder,station,'_SD.dat'));
    data = fscanf(fid,'%f',[5,inf])';
    SD = data(:,quarter)';
else folder = '/Users/stonek/work/Dobson/input/station_climatology/ozone_monthly/Standard_Deviation/';
    fid = fopen(strcat(folder,station,'_SD.dat'));
    data = fscanf(fid,'%f',[13,inf])';
    SD = data(:,date_to_use+1)';
end
C = .1; %.05, .1, .2, .8
%Roger's a priori covariance equation
for i = 1:length(extra.atmos.Z)
    for j = 1:length(extra.atmos.Z);
        COV(i,j) = C*extra.atmos.ozone(i)*extra.atmos.ozone(j)*exp(-(abs(i-j))/4);
    end
end


SD (SD <= 1e11) = 1e11;
% if logswitch
%     SD = log10(SD);
% end
Sa_temp = interp1(data(:,1)',SD,extra.atmos.Z,'linear','extrap');

scale_factor = 8; %was 8; 

%For testing optimal Sa (L-curve)
if L_curve_diag
    if i == 1
        Sa_temp = Sa_temp*scale_factor;
    else Sa_temp = Sa_temp.*mf;
    end
else Sa_temp = Sa_temp*scale_factor;
end

%scale_upper = ones(1,extra.atmos.nlayers-45);
scale_upper2 = 1:.1:5.5;
Sa_temp(1,extra.atmos.nlayers-45:end) = Sa_temp(extra.atmos.nlayers-45:end)./scale_upper2;

%Sa_temp(1,1:15) = Sa_temp(1,1:15)/10;

Sa_temp = Sa_temp.^2;
if logswitch
    Sa = diag(log10(Sa_temp));
else Sa = diag(Sa_temp);
end

%Sa1 = ones(1,15)*1e23;
%Sa2 = ones(1,66)*1e24;
%Sa = diag(horzcat(Sa1,Sa2));
%Sa = diag(ones(1,81)*1e24); %2e22
%Sa (Sa <= 1e22) = 1e22;
%sigma=log10(1e11);
%Sa = diag(ones(1,61).*sigma.^2);

Sa = COV; %To use Roger's definition with Irina's constants

end

