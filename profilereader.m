function [atmos date] = profilereader(Rvaluefilename,ozonefilename,temperaturefilename,pressurefilename,solarfilename,atmos,test)

%reads in atmospheric profiles to be put in atmos
%currently reading in
% - ozone
% - solar spectrum
% - temperature and pressure 

%for future inclusion
% -humidity

%reading in R-values, N-values, Time and trueSZA?
fid = fopen(Rvaluefilename,'r');
for i = 1:8;
    if i ~= 8;
        line = fgets(fid);
    else  headers = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s',1 );       
    end
end

data = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %c %f %f',[13,inf]);
sz = size(data);

for j = 1:sz(2);
    if strcmp(headers{1,j},'YEAR')
        date = struct(char(headers{1,j}), data{1,j}, char(headers{1,j+1}), data{1,j+1},...
           char(headers{1,j+2}), data{1,j+2}, char(headers{1,j+3}), data{1,j+3},...
           char(headers{1,j+4}), data{1,j+4},char(headers{1,j+5}), data{1,j+5});
    elseif strcmp(headers{1,j},'Solar_zenith_angle')
        angles = struct(char(headers{1,j}), data{1,j}, char(headers{1,j+1}), data{1,j+1});
    elseif strcmp(headers{1,j},'Wavelength_pair')
        atmos.wavelength_pair = struct(char(headers{1,j}), data{1,j});
    elseif strcmp(headers{1,j},'R_value');
        intensity_values = struct(char(headers{1,j}), data{1,j}, char(headers{1,j+1}), data{1,j+1});
    end
end
fclose(fid);


count = 1;
for j = 1:12;
    for i = 1:31;   
        location = find(date.DAY == i & date.MONTH == j); 
        if isempty(location) == 0            
            atmos.initial_SZA(count,1:length(location)) = angles.Solar_zenith_angle(min(location):max(location));
            atmos.N_values(count,1:length(location)) = intensity_values.N_Value(min(location):max(location));
            atmos.R_values(count,1:length(location)) = intensity_values.R_value(min(location):max(location));
            atmos.date(count,1:2) = horzcat(j,i);
            count = count+1;
        end
    end
end
atmos.N_values (atmos.N_values == 0) = NaN;
atmos.initial_SZA (atmos.initial_SZA == 0) = NaN;

date_to_use = atmos.date(test,1);

%reading in ozone profile
fid = fopen(ozonefilename);
%numlayers = fscanf(fid,'%i',1);

if date_to_use == 12 || date_to_use == 1 || date_to_use == 2
    quarter = 2;
elseif date_to_use == 3 || date_to_use == 4 || date_to_use == 5
    quarter = 3;
elseif date_to_use == 6 || date_to_use == 7 || date_to_use == 8
    quarter = 4;
elseif date_to_use == 9 || date_to_use == 10 || date_to_use == 11
    quarter = 5;
end
prof = fscanf(fid,'%f',[5,inf])';
atmos.ozone = interp1(prof(:,1),prof(:,quarter),atmos.Z,'linear','extrap');
atmos.ozonemid = interp1(prof(:,1),prof(:,quarter),atmos.Zmid,'linear','extrap');
fclose (fid);

%Reading in temperature.
fid = fopen(temperaturefilename);
temperature = fscanf(fid,'%f',[5,inf])';
atmos.T = interp1(temperature(:,1),temperature(:,quarter),atmos.Z,'linear','extrap');
atmos.Tmid = interp1(temperature(:,1),temperature(:,quarter),atmos.Zmid,'linear','extrap');
fclose(fid);

%Reading in pressure
fid = fopen(pressurefilename);
pressure = fscanf(fid,'%f',[5,inf])';
atmos.P = exp(interp1(pressure(:,1),log(pressure(:,quarter)),atmos.Z,'linear','extrap'));
atmos.Pmid = exp(interp1(pressure(:,1),log(pressure(:,quarter)),atmos.Zmid,'linear','extrap'));
fclose (fid);

% %reading in Temperature and Pressure
% fid = fopen(temppresfilename);
% tp = fscanf(fid,'%f',[3,numlayers])';
% atmos.T = tp(1:61,2)';
% atmos.P = tp(1:61,3)';
% atmos.Tmid = interp1(tp(:,1)*1000,tp(:,2),atmos.Zmid,'linear','extrap');
% atmos.Pmid = interp1(tp(:,1)*1000,tp(:,3),atmos.Zmid,'linear','extrap');
% fclose (fid);

%reading in solar spectrum
% micro-watts/(cm^2*nm)
files = dir(solarfilename);
NF = length(files);
solar(:,:).s = [];

for i = 1:NF;
    fid = fopen(strcat(solarfilename(1:51),files(i,1).name));
    solar(i).s = fscanf(fid,'%f',[3,inf]);
    fclose(fid);
end

atmos.solar = horzcat(solar.s)';
atmos.quarter = quarter;

end


 
