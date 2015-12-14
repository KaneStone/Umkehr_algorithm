function Sa = createSa(quarter,date_to_use,seasonal,logswitch,extra,i,...
    L_curve_diag,station,full_covariance,scale_factor)

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

if full_covariance
    %Roger's a priori covariance equation
    C = .1; %.05, .1, .2, .8
    for k = 1:length(extra.atmos.Z)
        for j = 1:length(extra.atmos.Z);
            COV(k,j) = C*extra.atmos.ozone(i)*extra.atmos.ozone(j)*exp(-(abs(k-j))/4);
        end
    end
    Sa = COV; %To use Roger's definition with Irina's constants
    return
end

SD (SD <= 1e11) = 1e11;
Sa_temp = interp1(data(:,1)',SD,extra.atmos.Z,'linear','extrap');
%scale_factor = 8; %was 8; 

Sa_temp = Sa_temp*scale_factor;    

scale_upper2 = 1:.1:5.5;
Sa_temp(1,extra.atmos.nlayers-45:end) = Sa_temp(extra.atmos.nlayers-45:end)./scale_upper2;

Sa_temp = Sa_temp.^2;
Sa = diag(Sa_temp);

% if logswitch
%     Sa = diag(log10(Sa_temp));
% else Sa = diag(Sa_temp);
% end
%Sa = diag(Sa_temp);

end

