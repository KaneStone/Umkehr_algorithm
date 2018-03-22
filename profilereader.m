function [atmos] = profilereader(atmos,Umkehr,inputs)

%reads in atmospheric profiles. 
% - ozone
% - temperature
% - pressure
% - aerosol

%% profile filenames
ozonefilename = ['../input/ForwardModelProfiles/ozone','/','Ozone_monthly.nc'];    
temperaturefilename = ['../input/ForwardModelProfiles/temperature','/','Temperature_monthly.nc'];    
pressurefilename = ['../input/ForwardModelProfiles/pressure','/','Pressure_monthly.nc'];    
aerosolfilename = ['../input/ForwardModelProfiles/','aerosol/netcdf/AerosolYearlyAverage.nc'];

%% finding month or season to use
atmos.Umkehrdate = datevec(Umkehr.data.Time(1));
atmos.dateindex = atmos.Umkehrdate(2);
if strcmp(inputs.seasonal, 'seasonal')
    if Umkehrdate(2) == 12 || Umkehrdate(2) == 1 || Umkehrdate(2) == 2
        atmos.dateindex = 2;
    elseif Umkehrdate(2) == 3 || Umkehrdate(2) == 4 || Umkehrdate(2) == 5
        atmos.dateindex = 3;
    elseif Umkehrdate(2) == 6 || Umkehrdate(2) == 7 || Umkehrdate(2) == 8
        atmos.dateindex = 4;
    elseif Umkehrdate(2) == 9 || Umkehrdate(2) == 10 || Umkehrdate(2) == 11
        atmos.dateindex = 5;
    end
end

%% importing data

[~, Ozonedata, ~] = readnetcdf(ozonefilename);
    [~,latindex] = min(abs(Ozonedata.Latitude - str2double(Umkehr.info.Attributes(1).Value)));
atmos.ozone = exp(interp1(Ozonedata.Height,log(squeeze(Ozonedata.O3(atmos.dateindex,latindex,:))), ...
    atmos.Z,'linear','extrap'));
atmos.ozone_mid = exp(interp1(Ozonedata.Height,log(squeeze(Ozonedata.O3(atmos.dateindex,latindex,:))), ...
    atmos.Zmid,'linear','extrap'));
atmos.ozoneSD = exp(interp1(Ozonedata.Height,log(squeeze(Ozonedata.Std(atmos.dateindex,latindex,:))), ...
    atmos.Z,'linear','extrap'));
atmos.ozoneSD_mid = exp(interp1(Ozonedata.Height,log(squeeze(Ozonedata.Std(atmos.dateindex,latindex,:))), ...
    atmos.Zmid,'linear','extrap'));

[~, Temperaturedata, ~] = readnetcdf(temperaturefilename);
    [~,latindex] = min(abs(Temperaturedata.Latitude - str2double(Umkehr.info.Attributes(1).Value)));
atmos.temperature = interp1(Temperaturedata.Height,squeeze(Temperaturedata.Temperature(atmos.dateindex,latindex,:)), ...
    atmos.Z,'linear','extrap');
atmos.temperature_mid = interp1(Temperaturedata.Height,squeeze(Temperaturedata.Temperature(atmos.dateindex,latindex,:)), ...
    atmos.Zmid,'linear','extrap');

[~, Pressuredata, ~] = readnetcdf(pressurefilename);
    [~,latindex] = min(abs(Pressuredata.Latitude - str2double(Umkehr.info.Attributes(1).Value)));
atmos.pressure = exp(interp1(Pressuredata.Height,log(squeeze(Pressuredata.Pressure(atmos.dateindex,latindex,:))), ...
    atmos.Z,'linear','extrap'));
atmos.pressure_mid = exp(interp1(Pressuredata.Height,log(squeeze(Pressuredata.Pressure(atmos.dateindex,latindex,:))), ...
    atmos.Zmid,'linear','extrap'));

%% aerosol
if strcmp(aerosolfilename(end-1:end),'nc')
    [~, Aerosoldata, ~] = readnetcdf(aerosolfilename);
    [~,latindex] = min(abs(Aerosoldata.Latitude - str2double(Umkehr.info.Attributes(1).Value)));    
    nf = find(squeeze(Aerosoldata.Extinction_525(latindex,:) ~= 0));
    
    atmos.aerosol = exp(interp1(nf*1000,squeeze(log(Aerosoldata.Extinction_525(latindex,nf))),...
        atmos.Z,'linear','extrap'))*1e-5;
    
    atmos.aerosol_mid = exp(interp1(nf*1000,squeeze(log(Aerosoldata.Extinction_525(latindex,nf))),...
        atmos.Zmid,'linear','extrap'))*1e-5;
    atmos.aerosol (isnan(atmos.aerosol)) = 0;
    atmos.aerosol_mid (isnan(atmos.aerosol_mid)) = 0;
else    

end

atmos.solar = read_solar(atmos);

end