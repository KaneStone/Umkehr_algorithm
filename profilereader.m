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
for i = 1:6;
    if i ~= 6;
        line = fgets(fid);
    else  headers = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s',1 );       
    end
end

data = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %c %f %f',[13,inf]);
sz = size(data);

for j = 1:sz(2);
    if strcmp(headers{1,j},'YYYY')
        date_of_meas = struct(char(headers{1,j}), data{1,j}, char(headers{1,j+1}), data{1,j+1},...
           char(headers{1,j+2}), data{1,j+2}, char(headers{1,j+3}), data{1,j+3},...
           char(headers{1,j+4}), data{1,j+4},char(headers{1,j+5}), data{1,j+5});
    elseif strcmp(headers{1,j},'Solar_zenith_angle')
        angles = struct(char(headers{1,j}), data{1,j}, char(headers{1,j+1}), data{1,j+1});
    elseif strcmp(headers{1,j},'Wavelength_Pair')
        wavelength_pair = struct(char(headers{1,j}), data{1,j});
    elseif strcmp(headers{1,j},'R_value');
        intensity_values = struct(char(headers{1,j}), data{1,j}, char(headers{1,j+1}), data{1,j+1});
    end
end
fclose(fid);

%need to separate diffeerent measurments that are on same day
% count = 1;
% for j = 1:12;
%     for i = 1:31;   
%         location = find(date_of_meas.DD == i & date_of_meas.MM == j); 
%         hour = date_of_meas.HH(location);        
%         if isempty(location) == 0                              
%             atmos.WLP(count,1:length(location)) = wavelength_pair.Wavelength_Pair(min(location):max(location));                       
%             what_WLP.a = strfind(atmos.WLP(count,:),'A');
%             what_WLP.c = strfind(atmos.WLP(count,:),'C');
%             what_WLP.d = strfind(atmos.WLP(count,:),'D');
%             atmos.initial_SZA(count,1:length(location)) = angles.Solar_zenith_angle(min(location):max(location));
%             atmos.N_values(count,1:length(location)) = intensity_values.N_value(min(location):max(location));
%             atmos.R_values(count,1:length(location)) = intensity_values.R_value(min(location):max(location));
%             atmos.date(count,1:2) = horzcat(j,i);
%             count = count+1;
%         end
%     end
% end

position_handle = 1;
count = 1;
for j = 1:12;
    for i = 1:31;   
        location = find(date_of_meas.DD == i & date_of_meas.MM == j); 
        hour = date_of_meas.HH(location);        
        if isempty(location) == 0                              
            atmos.WLP(count,1:length(location)) = wavelength_pair.Wavelength_Pair(min(location):max(location));                       
            what_WLP.a = strfind(atmos.WLP(count,:),'A');
            what_WLP.c = strfind(atmos.WLP(count,:),'C');
            what_WLP.d = strfind(atmos.WLP(count,:),'D');
            atmos.date(count).date = horzcat(i,j,date_of_meas.YYYY(1));
            
            if isempty(what_WLP.a) == 0
                atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.a)) = angles.Solar_zenith_angle(what_WLP.a(1):what_WLP.a(end));
                atmos.N_values(count).WLP(position_handle) = 'A';
                atmos.N_values(count).N(position_handle,1:length(what_WLP.a)) = intensity_values.N_value(what_WLP.a(1):what_WLP.a(end));
                atmos.R_values(count).R(position_handle,1:length(what_WLP.a)) = intensity_values.R_value(what_WLP.a(1):what_WLP.a(end));
                position_handle = position_handle+1;                
            end            
            if isempty(what_WLP.c) == 0
                atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.c)) = angles.Solar_zenith_angle(what_WLP.c(1):what_WLP.c(end));
                atmos.N_values(count).WLP(position_handle) = 'C';
                atmos.N_values(count).N(position_handle,1:length(what_WLP.c)) = intensity_values.N_value(what_WLP.c(1):what_WLP.c(end));
                atmos.R_values(count).R(position_handle,1:length(what_WLP.c)) = intensity_values.N_value(what_WLP.c(1):what_WLP.c(end));
                position_handle = position_handle+1;                
            end
            if isempty(what_WLP.d) == 0
                atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.d)) = angles.Solar_zenith_angle(what_WLP.d(1):what_WLP.d(end));
                atmos.N_values(count).WLP(position_handle) = 'D';
                atmos.N_values(count).N(position_handle,1:length(what_WLP.d)) = intensity_values.R_value(what_WLP.d(1):what_WLP.d(end));
                atmos.R_values(count).R(position_handle,1:length(what_WLP.d)) = intensity_values.R_value(what_WLP.d(1):what_WLP.d(end));                
            end

            count = count+1;            
        end
    end
end


%atmos.N_values (atmos.N_values == 0) = [];
%atmos.initial_SZA(1).SZA (atmos.initial_SZA(1).SZA == 0) = [];

date_to_use = atmos.date(test).date(2);

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


 
