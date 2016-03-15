function [atmos] = profilereader(atmos,Umkehr,inputs)

%reads in atmospheric profiles. 
% - ozone
% - temperature
% - pressure
% - aerosol

%profile filenames
ozonefilename = ['../input/ForwardModelProfiles/',inputs.station,'/',...
    inputs.seasonal,'/', inputs.station,'_ozone_',inputs.seasonal,'.dat'];
ozoneSDfilename = ['../input/ForwardModelProfiles/',inputs.station,'/', ...
    inputs.seasonal, '/',inputs.station,'_ozone_',inputs.seasonal,'_SD.dat'];
temperaturefilename = ['../input/ForwardModelProfiles/',inputs.station,'/',...
    inputs.seasonal, '/',inputs.station,'_temperature_',inputs.seasonal,'.dat'];
pressurefilename = ['../input/ForwardModelProfiles/',inputs.station,'/', ...
    inputs.seasonal,'/',inputs.station, '_pressure_',inputs.seasonal,'.dat'];
aerosolfilename = ['../input/ForwardModelProfiles/','aerosol/AntAero10_9.dat'];

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

%importing data
%ozone
ozoneprofile = importdata(ozonefilename);
atmos.ozone = exp(interp1(ozoneprofile(:,1),log(ozoneprofile(:,atmos.dateindex+1)), ...
    atmos.Z,'linear','extrap'));
atmos.ozone_mid = exp(interp1(ozoneprofile(:,1),log(ozoneprofile(:,atmos.dateindex+1)), ...
    atmos.Zmid,'linear','extrap'));

%ozone standard deviation
ozoneSDprofile = importdata(ozoneSDfilename);
atmos.ozoneSD = exp(interp1(ozoneSDprofile(:,1),log(ozoneSDprofile(:,atmos.dateindex+1)), ...
    atmos.Z,'linear','extrap'));
atmos.ozoneSD_mid = exp(interp1(ozoneSDprofile(:,1),log(ozoneSDprofile(:,atmos.dateindex+1)), ...
    atmos.Zmid,'linear','extrap'));

%temperature
temperatureprofile = importdata(temperaturefilename);
atmos.temperature = exp(interp1(temperatureprofile(:,1),...
    log(temperatureprofile(:,atmos.dateindex+1)),atmos.Z,'linear','extrap'));
atmos.temperature_mid = interp1(temperatureprofile(:,1),...
    temperatureprofile(:,atmos.dateindex+1),atmos.Zmid,'linear','extrap');

%pressure
pressureprofile = importdata(pressurefilename);
atmos.pressure = exp(interp1(pressureprofile(:,1),...
    log(pressureprofile(:,atmos.dateindex+1)),atmos.Z,'linear','extrap'));
atmos.pressure_mid = exp(interp1(pressureprofile(:,1),...
    log(pressureprofile(:,atmos.dateindex+1)),atmos.Zmid,'linear','extrap'));

%aerosol
aerosol = importdata(aerosolfilename);
atmos.aerosol = aerosol(1:inputs.maximum_altitude / 1000 + 1,2)';
atmos.aerosol_mid = exp(interp1(aerosol(:,1),log(aerosol(:,2)),atmos.Zmid,'linear','extrap'));

end