function [atmos] = profilereader(atmos,Umkehr,inputs)

%reads in atmospheric profiles. 
% - ozone
% - temperature
% - pressure
% - aerosol

%profile filenames
% ozonefilename = ['../input/ForwardModelProfiles/',inputs.station,'/',...
%     inputs.seasonal,'/', inputs.station,'_ozone_',inputs.seasonal,'.dat'];
ozonefilename = ['../input/ForwardModelProfiles/ozone','/','Ozone_monthly.nc'];    
temperaturefilename = ['../input/ForwardModelProfiles/temperature','/','Temperature_monthly.nc'];    
pressurefilename = ['../input/ForwardModelProfiles/pressure','/','Pressure_monthly.nc'];    
%ozoneSDfilename = ['../input/ForwardModelProfiles/',inputs.station,'/', ...
%    inputs.seasonal, '/',inputs.station,'_ozone_',inputs.seasonal,'_SD.dat'];
% temperaturefilename = ['../input/ForwardModelProfiles/',inputs.station,'/',...
%     inputs.seasonal, '/',inputs.station,'_temperature_',inputs.seasonal,'.dat'];
% pressurefilename = ['../input/ForwardModelProfiles/',inputs.station,'/', ...
%     inputs.seasonal,'/',inputs.station, '_pressure_',inputs.seasonal,'.dat'];
%aerosolfilename = ['../input/ForwardModelProfiles/','aerosol/AntAero10_9.dat'];
aerosolfilename = ['../input/ForwardModelProfiles/','aerosol/netcdf/AerosolYearlyAverage.nc'];

%finding month or season to use
atmos.Umkehrdate = datevec(Umkehr.data.Time(1));
atmos.dateindex = atmos.Umkehrdate(2);
if strcmp(inputs.seasonal, 'seasonal'); 
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

%Irina's
%load('/Users/kanestone/Documents/MATLAB/Iin.mat');

%importing data
%ozone
% ozoneprofile = importdata(ozonefilename);
% atmos.ozone = exp(interp1(ozoneprofile(:,1),log(ozoneprofile(:,atmos.dateindex+1)), ...
%     atmos.Z,'linear','extrap'));
% atmos.ozone_mid = exp(interp1(ozoneprofile(:,1),log(ozoneprofile(:,atmos.dateindex+1)), ...
%     atmos.Zmid,'linear','extrap'));

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
%atmos.temperature = ones(1,81)*300;
atmos.temperature_mid = interp1(Temperaturedata.Height,squeeze(Temperaturedata.Temperature(atmos.dateindex,latindex,:)), ...
    atmos.Zmid,'linear','extrap');
%atmos.temperature_mid = ones(1,80)*300;

[~, Pressuredata, ~] = readnetcdf(pressurefilename);
    [~,latindex] = min(abs(Pressuredata.Latitude - str2double(Umkehr.info.Attributes(1).Value)));
atmos.pressure = exp(interp1(Pressuredata.Height,log(squeeze(Pressuredata.Pressure(atmos.dateindex,latindex,:))), ...
    atmos.Z,'linear','extrap'));
%atmos.pressure = exp(interp1(Ialt2(1:61)*1000,log(Ipres), ...
%    atmos.Z,'linear','extrap'));
atmos.pressure_mid = exp(interp1(Pressuredata.Height,log(squeeze(Pressuredata.Pressure(atmos.dateindex,latindex,:))), ...
    atmos.Zmid,'linear','extrap'));

% Irina's pressure

% load('Irina.mat');
% load('melbourneTaP');
% 
% atmos.pressure2 = exp(interp1(Melbourne(1,:),log(Melbourne(2,:)/100), ...
%     atmos.Z,'linear','extrap'));
% atmos.temp2 = exp(interp1(Melbourne(1,:),log(Melbourne(2,:)/100), ...
%     atmos.Z,'linear','extrap'));
% %atmos.pressure = exp(interp1(Ialt2(1:61)*1000,log(Ipres), ...
% %    atmos.Z,'linear','extrap'));
% atmos.pressure_mid = exp(interp1(Pressuredata.Height,log(squeeze(Pressuredata.Pressure(atmos.dateindex,latindex,:))), ...
%     atmos.Zmid,'linear','extrap'));

%ozone standard deviation
% ozoneSDprofile = importdata(ozoneSDfilename);
% atmos.ozoneSD = exp(interp1(ozoneSDprofile(:,1),log(ozoneSDprofile(:,atmos.dateindex+1)), ...
%     atmos.Z,'linear','extrap'));
% atmos.ozoneSD_mid = exp(interp1(ozoneSDprofile(:,1),log(ozoneSDprofile(:,atmos.dateindex+1)), ...
%     atmos.Zmid,'linear','extrap'));

%temperature
% temperatureprofile = importdata(temperaturefilename);
% atmos.temperature = exp(interp1(temperatureprofile(:,1),...
%     log(temperatureprofile(:,atmos.dateindex+1)),atmos.Z,'linear','extrap'));
% atmos.temperature_mid = interp1(temperatureprofile(:,1),...
%     temperatureprofile(:,atmos.dateindex+1),atmos.Zmid,'linear','extrap');
% 
% %pressure
% pressureprofile = importdata(pressurefilename);
% atmos.pressure = exp(interp1(pressureprofile(:,1),...
%     log(pressureprofile(:,atmos.dateindex+1)),atmos.Z,'linear','extrap'));
% atmos.pressure_mid = exp(interp1(pressureprofile(:,1),...
%     log(pressureprofile(:,atmos.dateindex+1)),atmos.Zmid,'linear','extrap'));

%aerosol
if strcmp(aerosolfilename(end-1:end),'nc');
    [Aerosolinfo, Aerosoldata, AerosolAttributes] = readnetcdf(aerosolfilename);
    [~,latindex] = min(abs(Aerosoldata.Latitude - str2num(Umkehr.info.Attributes(1).Value)));
    timeindex = atmos.Umkehrdate(2);
    nf = find(squeeze(Aerosoldata.Extinction_525(latindex,:) ~= 0));
    
    atmos.aerosol = exp(interp1(nf*1000,squeeze(log(Aerosoldata.Extinction_525(latindex,nf))),...
        atmos.Z,'linear','extrap'))*1e-5;
    
    atmos.aerosol_mid = exp(interp1(nf*1000,squeeze(log(Aerosoldata.Extinction_525(latindex,nf))),...
        atmos.Zmid,'linear','extrap'))*1e-5;
    atmos.aerosol (isnan(atmos.aerosol)) = 0;
    atmos.aerosol_mid (isnan(atmos.aerosol_mid)) = 0;
else    
%     load('/Users/kanestone/work/projects/Umkehr/input/ForwardModelProfiles/aerosol/test.mat');
%     %aerosol(:,2) = aerosol(:,2);
%     meandata = meandata*1e-5;
%     meandata (isnan(meandata)) = 0;
    %aerosol(1:5,2) = 0;
    % aerosol = [aerosol(:,1),[zeros(1,10)'; aerosol(6:end-5,2)]];
%     atmos.aerosol = aerosol(1:inputs.maximum_altitude / 1000 + 1,2)';
%     atmos.aerosol_mid = exp(interp1(aerosol(:,1),log(aerosol(:,2)),atmos.Zmid,'linear','extrap'));

    %atmos.aerosol(1:30) = atmos.aerosol(1:30)*20;
    %atmos.aerosol_mid(1:30) = atmos.aerosol_mid(1:30)*20;

%     atmos.aerosol = exp(interp1(12000:1000:38000,log(meandata(12:38)),atmos.Z,'linear','extrap'));
%     atmos.aerosol_mid = exp(interp1(12000:1000:38000,log(meandata(12:38)),atmos.Zmid,'linear','extrap'));
    %atmos.aerosol(31:end) = 0;
    %atmos.aerosol_mid(31:end) = 0;

end
%  aerosolfilename = ['../input/ForwardModelProfiles/','aerosol/AntAero10_9.dat'];
%  aerosol1 = importdata(aerosolfilename);
%  atmos.aerosol = aerosol1(1:inputs.maximum_altitude / 1000 + 1,2)';
%  atmos.aerosol_mid = exp(interp1(aerosol1(:,1),log(aerosol1(:,2)),atmos.Zmid,'linear','extrap'));

atmos.solar = read_solar(atmos);

end