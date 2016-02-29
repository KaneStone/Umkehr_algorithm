function Sa = createSa(quarter,date_to_use,seasonal,logswitch,extra,i,...
    L_curve_diag,station,covariance_type,scale_factor)

if strcmp(seasonal,'seasonal')
    folder = '../input/station_climatology/ozone/Standard_Deviation/';
    fid = fopen(strcat(folder,station,'_SD.dat'));
    data = fscanf(fid,'%f',[5,inf])';
    SD = data(:,quarter)';
    SD = interp1(data(:,1)',SD,extra.atmos.Z,'linear','extrap');
elseif strcmp(seasonal,'monthly') 
    folder = '../input/station_climatology/ozone_monthly/Standard_Deviation/';
    fid = fopen(strcat(folder,station,'.dat'));
    data = fscanf(fid,'%f',[13,inf])';
    SD = data(:,date_to_use+1)';
    SD = interp1(data(:,1)',SD,extra.atmos.Z,'linear','extrap');
end


scale_upper2 = 1:.1:5.5;
scale_lower2 = 6:-.2:1;
%scale_lower2 = 4:-.2:1;
SD (SD <= 1e11) = 1e11; 
%SD (SD >= 6e11) = 6e11; 
Sa_temp = SD*scale_factor;    
%Sa_temp (Sa_temp >= 6e11) = 6e11; 
%Sa_temp(35:end) = 1e11; 
Sa_temp(1,extra.atmos.nlayers-45:end) = Sa_temp(extra.atmos.nlayers-45:end)./scale_upper2;
Sa_temp(1,1:26) = Sa_temp(1,1:26)./scale_lower2;
%Sa_temp(1,1:16) = Sa_temp(1,1:16)./scale_lower2;
 
if strcmp(covariance_type,'full_covariance');
    %Roger's a priori covariance equation
%     SD(1,extra.atmos.nlayers-45:end) = SD(1,extra.atmos.nlayers-45:end)./scale_upper2;
    C = 1; %.05, .1, .2, .8
    for k = 1:length(extra.atmos.Z)
        for j = 1:length(extra.atmos.Z);
            %COV(k,j) = C*extra.atmos.ozone(k)*extra.atmos.ozone(j)*exp(-(abs(k-j))*1/4);            
            COV(k,j) = C*Sa_temp(k)*Sa_temp(j)*exp(-(abs(k-j))/7);
            %COV(k,j) = C*1e11*1e11*exp(-(abs(k-j))/7);
        end
    end    
    Sa = COV; %To use Roger's definition with Irina's constants        
    %Sa = diag(diag(COV),0);
    return
elseif strcmp(covariance_type,'constant');
    maxvariance = max(SD);
    Sa_temp = repmat(maxvariance,81,1).*2;
    Sa_temp(extra.atmos.nlayers-45:end,1) = Sa_temp(extra.atmos.nlayers-45:end)./scale_upper2';
    Sa = diag(Sa_temp,0).^2; 
    return
end

 
%SD (SD <= 1e11) = 1e11;
%Sa_temp = interp1(data(:,1)',SD,extra.atmos.Z,'linear','extrap');
%scale_factor = 8; %was 8; 



Sa_temp = Sa_temp.^2;
Sa = diag(Sa_temp,0);

% if logswitch
%     Sa = diag(log10(Sa_temp));
% else Sa = diag(Sa_temp);
% end
%Sa = diag(Sa_temp);

end

