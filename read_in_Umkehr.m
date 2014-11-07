function [atmos measurement_length] = read_in_Umkehr(measurementfilename)

%reading in headers
fid = fopen(measurementfilename,'r');
tline = fgetl(fid);
rowcount = 1;
while ischar(tline)
    tline = fgetl(fid);
    if strcmp(tline(1:29),'! The columns are as follows:')
        headers = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s',1 ); 
        break
    end
    rowcount = rowcount+1;
end

%Reading in data
data = fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %c %f %f',[13,inf])';
%removing missing data
data (data == -9999) = NaN;
data = data(~any(isnan(data),2),:); 
sz = size(data);

%Extracting date, SZA, WLP, R-value, and N-value
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

%Seperating into separate measurements
N_temp_C = [];
R_temp_C = [];
SZA_temp_C = [];
WLP_temp_C = [];
atmos.WLP = zeros(49,500);
WLP_month_C = zeros(12,500);
position_handle = 1;
count = 1;
for j = 1:12;
    for i = 1:31;   
        location = find(date_of_meas.DD == i & date_of_meas.MM == j);
        
        if isempty(location) == 0     
            atmos.hour_min(count) = min(date_of_meas.HH(location));
            atmos.hour_max(count) = max(date_of_meas.HH(location));
            atmos.date(count).date = horzcat(i,j,date_of_meas.YYYY(1));                                                 
            atmos.WLP(count,1:length(location)) =...
                Wavelength_pair.Wavelength_Pair(min(location):max(location));   
            
            what_WLP.a = location(strfind(atmos.WLP(count,:),'A'));
            if isempty(what_WLP.a) == 0     
                atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.a)) = angles.Solar_zenith_angle(what_WLP.a);
                atmos.N_values(count).WLP(position_handle) = 'A';
                atmos.N_values(count).N(position_handle,1:length(what_WLP.a)) = intensity_values.N_value(what_WLP.a);
                atmos.R_values(count).R(position_handle,1:length(what_WLP.a)) = intensity_values.R_value(what_WLP.a);
                position_handle = position_handle+1;
            end            

            what_WLP.c = location(strfind(atmos.WLP(count,:),'C'));            
            if isempty(what_WLP.c) == 0                
                %atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.c)) = angles.Solar_zenith_angle(location(1)-1+what_WLP.c(1):location(1)-1+what_WLP.c(end));
                atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.c)) = angles.Solar_zenith_angle(what_WLP.c);
                atmos.N_values(count).WLP(position_handle) = 'C';                
                atmos.N_values(count).N(position_handle,1:length(what_WLP.c)) = intensity_values.N_value(what_WLP.c);               
                atmos.R_values(count).R(position_handle,1:length(what_WLP.c)) = intensity_values.R_value(what_WLP.c);
                
                N_temp_C = [N_temp_C intensity_values.N_value(what_WLP.c)'];
                R_temp_C = [R_temp_C intensity_values.R_value(what_WLP.c)'];
                SZA_temp_C = [SZA_temp_C angles.Solar_zenith_angle(what_WLP.c)'];
                WLP_temp_C = [WLP_temp_C atmos.WLP(count,:)];
                position_handle = position_handle+1;                
            end

            what_WLP.d = location(strfind(atmos.WLP(count,:),'D'));
            if isempty(what_WLP.d) == 0     
                atmos.initial_SZA(count).SZA(position_handle,1:length(what_WLP.d)) = angles.Solar_zenith_angle(what_WLP.d);
                atmos.N_values(count).WLP(position_handle) = 'D';
                atmos.N_values(count).N(position_handle,1:length(what_WLP.d)) = intensity_values.N_value(what_WLP.d);
                atmos.R_values(count).R(position_handle,1:length(what_WLP.d)) = intensity_values.R_value(what_WLP.d); 
            end
            atmos.MAX_SZA(count) = max(max(atmos.initial_SZA(count).SZA)); 
            atmos.MIN_SZA(count) = min(min(atmos.initial_SZA(count).SZA)); 
            count = count+1; 
            position_handle = 1;
        end       
    end
    
    %inificient code for testing monthly vector retrievals-----
    N_month_C(j).N = N_temp_C;
    N_month_C(j).WLP = 'C';
    R_month_C(j).R = R_temp_C;
    SZA_month_C(j).SZA = SZA_temp_C;
    WLP_temp_C (WLP_temp_C ~= 67) = [];
    WLP_month_C(j,1:length(WLP_temp_C)) = WLP_temp_C;
    N_temp_C = [];
    R_temp_C = [];
    SZA_temp_C = [];
    WLP_temp_C = [];
    %----------------------------------------------------------
end
measurement_length = length(atmos.N_values);

atmos.N_values = horzcat(atmos.N_values,N_month_C);
atmos.R_values = horzcat(atmos.R_values,R_month_C);
atmos.initial_SZA = horzcat(atmos.initial_SZA,SZA_month_C);
atmos.date = horzcat(atmos.date,atmos.date(1:12));
atmos.WLP = vertcat(atmos.WLP,WLP_month_C);
end