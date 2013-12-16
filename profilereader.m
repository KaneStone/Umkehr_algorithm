function [atmos date] = profilereader(measurementfilename,ozonefilename,temperaturefilename,...
    pressurefilename,solarfilename,aerosolfilename,atmos,measurement_number,WLP,morn_or_even)

%reads in measurements and atmospheric profiles.
%currently reading in
% - measurments
% - ozone
% - temperature and pressure
% - aerosols
% - solar spectrum

%reading in R-values, N-values, Time and trueSZA
fid = fopen(measurementfilename,'r');
for i = 1:6;
    if i ~= 6;
        information{i} = fgets(fid);
    else  headers = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s',1 );                   
    end
end

data = fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %c %f %f',[13,inf])';
%removing missing data
data (data == -9999) = NaN;
data = data(~any(isnan(data),2),:); 

sz = size(data);

for j = 1:sz(2);
    if strcmp(headers{1,j},'YYYY')
        date_of_meas = struct(char(headers{1,j}), data(:,j), char(headers{1,j+1}), data(:,j+1),...
           char(headers{1,j+2}), data(:,j+2), char(headers{1,j+3}), data(:,j+3),...
           char(headers{1,j+4}), data(:,j+4),char(headers{1,j+5}), data(:,j+5));
    elseif strcmp(headers{1,j},'Solar_zenith_angle')
        angles = struct(char(headers{1,j}), data(:,j), char(headers{1,j+1}), data(:,j+1));
    elseif strcmp(headers{1,j},'Wavelength_Pair')
        Wavelength_pair = struct(char(headers{1,j}), data(:,j));
    elseif strcmp(headers{1,j},'R_value');
        intensity_values = struct(char(headers{1,j}), data(:,j), char(headers{1,j+1}), data(:,j+1));
    end
end
fclose(fid);

position_handle = 1;
count = 1;
for j = 1:12;
    for i = 1:31;   
        location = find(date_of_meas.DD == i & date_of_meas.MM == j);       
        if isempty(location) == 0                
            atmos.date(count).date = horzcat(i,j,date_of_meas.YYYY(1));                                   
            hour = date_of_meas.HH(location);
            
            %separating measurements morning and evening measuremnets -
            %maybe not infallable.
            if max(hour) - min(hour) >=9 
                disp(strcat('Both morning and evening measurements were taken at date: ',...
                    num2str(atmos.date(count).date(1))...
                    ,'-',num2str(atmos.date(count).date(2))...
                    ,'-',num2str(atmos.date(count).date(3)),', continuing with specified case.'));                                                 
                if strcmp(morn_or_even,'evening');
                    location (hour <= 12) = []; %This is not infallable 
                elseif strcmp(morn_or_even,'morning');
                    location (hour >= 12) = [];
                end
            end            
            atmos.WLP(count,1:length(location)) =...
                Wavelength_pair.Wavelength_Pair(min(location):max(location));            
            if find(WLP == 'A')                
                what_WLP.a = strfind(atmos.WLP(count,:),'A');
                if isempty(what_WLP.a) == 0     
                    atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.a)) = angles.Solar_zenith_angle(location(1):location(1)-1+what_WLP.a(end));
                    atmos.N_values(count).WLP(position_handle) = 'A';
                    atmos.N_values(count).N(position_handle,1:length(what_WLP.a)) = intensity_values.N_value(location(1):location(1)-1+what_WLP.a(end));
                    atmos.R_values(count).R(position_handle,1:length(what_WLP.a)) = intensity_values.R_value(location(1):location(1)-1+what_WLP.a(end));
                    position_handle = position_handle+1;
                end
            end
            if find(WLP == 'C')
                what_WLP.c = strfind(atmos.WLP(count,:),'C');
                if isempty(what_WLP.c) == 0                
                    atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.c)) = angles.Solar_zenith_angle(location(1)-1+what_WLP.c(1):location(1)-1+what_WLP.c(end));
                    atmos.N_values(count).WLP(position_handle) = 'C';
                    atmos.N_values(count).N(position_handle,1:length(what_WLP.c)) = intensity_values.N_value(location(1)-1+what_WLP.c(1):location(1)-1+what_WLP.c(end));
                    atmos.R_values(count).R(position_handle,1:length(what_WLP.c)) = intensity_values.R_value(location(1)-1+what_WLP.c(1):location(1)-1+what_WLP.c(end));
                    position_handle = position_handle+1;                
                end
            end
            if find(WLP == 'D')
                what_WLP.d = strfind(atmos.WLP(count,:),'D');
                if isempty(what_WLP.d) == 0     
                    atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.d)) = angles.Solar_zenith_angle(location(1)-1+what_WLP.d(1):location(1)-1+what_WLP.d(end));
                    atmos.N_values(count).WLP(position_handle) = 'D';
                    atmos.N_values(count).N(position_handle,1:length(what_WLP.d)) = intensity_values.N_value(location(1)-1+what_WLP.d(1):location(1)-1+what_WLP.d(end));
                    atmos.R_values(count).R(position_handle,1:length(what_WLP.d)) = intensity_values.R_value(location(1)-1+what_WLP.d(1):location(1)-1+what_WLP.d(end)); 
                end
            end                                            
            count = count+1; 
            position_handle = 1;
        end
    end
end

disp(strcat({'Current date being retrieved: '},num2str(atmos.date(measurement_number).date(1))...
    ,'-',num2str(atmos.date(measurement_number).date(2))...
    ,'-',num2str(atmos.date(measurement_number).date(3))));
No_WLP = length(WLP);

existing_WLP = atmos.WLP(measurement_number,:);
A = ' '; C = ' '; D = ' ';
if strfind(existing_WLP,'A');
    A = 'A';
elseif strfind(existing_WLP,'C');
    C = 'C';
elseif strfind(existing_WLP,'D');
    D = 'D';
end

if isempty(atmos.N_values(measurement_number).WLP);
    error(strcat('No measurements for the wavelengths specified exist for date:',...
    num2str(atmos.date(measurement_number).date(1)),'-',num2str(atmos.date(measurement_number).date(2))...
    ,'-',num2str(atmos.date(measurement_number).date(3)),'. wavelength pairs that exist are-',A,C,D));
end

for k = 1:No_WLP
    if (WLP(k) == atmos.N_values(measurement_number).WLP) == 0
    display(strcat(WLP(k),{' pair measurement does not exist at this date or was removed.'},...
        {' Continuing with other wavelength pairs specified'}))
    end
end
    
%checking whether vector lengths are the same
no_zeros = nonzeros(atmos.initial_SZA(measurement_number).SZA');
sz_SZA = size(atmos.initial_SZA(measurement_number).SZA);
if length(no_zeros) ~= length(reshape(atmos.initial_SZA(measurement_number).SZA,1,sz_SZA(1)*sz_SZA(2)))
    disp(strcat('Inconsistent vector lengths of different wavelength pairs for date:',...
        num2str(atmos.date(measurement_number).date(1)),'-',num2str(atmos.date(measurement_number).date(2))...
        ,'-',num2str(atmos.date(measurement_number).date(3))));
end

%removing padded zeros if wavelength pair data sizes are different.
atmos.N_values(measurement_number).N (atmos.N_values(measurement_number).N(:,:) == 0) = NaN;
atmos.initial_SZA(measurement_number).SZA (atmos.initial_SZA(measurement_number).SZA(:,:) == 0) = NaN;

date_to_use = atmos.date(measurement_number).date(2);

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

%Reading in aerosols
%These aerosols are for extinction at 500nm. To calculate extinction at
%otehr wavenegths: *(500/lambda)^1.2
fid = fopen(aerosolfilename);
aerosol = fscanf(fid,'%f',[2,inf])';
aerosol = aerosol(2:71,:);
atmos.Aer = interp1(aerosol(:,1),aerosol(:,2),atmos.Z,'linear','extrap');
atmos.Aermid = interp1(aerosol(:,1),aerosol(:,2),atmos.Zmid,'linear','extrap');
fclose (fid);

atmos.quarter = quarter;     
end