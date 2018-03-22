function [Umkehr] = readUmkehr(inputs)

if strcmp(inputs.morn_or_even,'Both')
    inputs.morn_or_even = [];
end

if length(inputs.daterange) == 1 && length(num2str(inputs.daterange)) ~= 6
    % Individual measurement
    date = num2str(inputs.daterange);
    year = date(1:4);
    file = dir(['../input/Umkehr/netcdftest/',inputs.station,'/',year,...
        '/',inputs.station, '_',num2str(inputs.daterange),'_',inputs.morn_or_even,'*.nc']);
    [Umkehr.info,Umkehr.data,Umkehr.attributes] = ...
        readnetcdf(['../input/Umkehr/netcdftest/',inputs.station,'/',year,'/'...
        ,file.name]);
elseif length(inputs.daterange) == 1 && length(num2str(inputs.daterange)) == 6
    % Individual measurement
    date = num2str(inputs.daterange);
    year = date(1:4);
    files = dir(['../input/Umkehr/netcdftest/',inputs.station,'/',year,...
        '/',inputs.station, '_',num2str(inputs.daterange),'*.nc']);
    for i = 1:length(files)
        [Umkehr(i).info,Umkehr(i).data,Umkehr(i).attributes] = ...
            readnetcdf(['../input/Umkehr/netcdftest/',inputs.station,'/',year,'/'...
            ,files(i).name]);
    end
elseif  length(inputs.daterange) == 2
    % Multiple measurements
    start_str = num2str(inputs.daterange(1));
    end_str = num2str(inputs.daterange(2));
    year_start = start_str(1:4);
    year_end = end_str(1:4);    
    
    %this needs to be fixed
    if strcmp(year_start,year_end)
        month_start = start_str(5:6);
        month_end = end_str(5:6);
        monthcount = month_start;
        for i = 1:str2double(month_end)-str2double(month_start)+1
            files(i).f = dir([...
                '../input/Umkehr/netcdftest/',inputs.station,'/',year_start,...
                '/',inputs.station,'_',year_start,monthcount,'*',inputs.morn_or_even,'.nc']);
            monthcount = sprintf('%02d%',str2double(monthcount)+1);
        end
        files_year = vertcat(files(:).f);
        for i = 1:length(files_year)
            [Umkehr(i).info, Umkehr(i).data, Umkehr(i).attributes] = ...
                readnetcdf(['../input/Umkehr/netcdftest/',inputs.station,'/',year_start,...
                '/',files_year(i).name]);                    
        end          
    else     
        allfiles = [];
        yearcount = year_start;
        count = 1;
        for j = 1:str2double(year_end)-str2double(year_start)+1                         
            if j ~= 1 && j ~= length(1:str2double(year_end)-str2double(year_start)+1)
                monthcount = '01';
                month_start = '01';                            
                month_end = '12';
            elseif j == 1   
                month_start = start_str(5:6);
                monthcount = month_start;
                month_end = '12';                                            
            elseif j == length(1:str2double(year_end)-str2double(year_start)+1)
                monthcount = '01';
                month_start = '01';   
                month_end = end_str(5:6);
            end
            for i = 1:str2double(month_end)-str2double(month_start)+1
                files(i).f = dir([...
                    '../input/Umkehr/netcdftest/',inputs.station, '/',yearcount,...
                    '/',inputs.station,'_',yearcount,monthcount,'*.nc']);
                monthcount = sprintf('%02d%',str2double(monthcount)+1);
                count1 = 1;
                
                % morning or evening
                if strcmp(inputs.morn_or_even,'Morning') || strcmp(inputs.morn_or_even,'Evening')
                    for k = 1:length(files.f)
                        temp = files.f(k).name;
                        moe = strfind(temp,inputs.morn_or_even);
                        if ~isempty(moe)
                            moe_index(count1) = k;
                            count1 = count1+1;
                        end
                    end
                    files(i).f = files(i).f(moe_index);                                     
                end
            end
            files_year = vertcat(files(:).f);
            
            for i = 1:length(files_year)
                [Umkehr(count).info, Umkehr(count).data, Umkehr(count).attributes] = ...
                    readnetcdf(['../input/Umkehr/netcdftest/',inputs.station, '/',...
                    yearcount,'/',files_year(i).name]);        
                count = count + 1;
            end                            
            clearvars files_temp  
            allfiles = [allfiles;files_year];
            yearcount = num2str(str2double(yearcount)+1);
            clearvars files_year files
        end           
    end       
end


for i = 1:length(Umkehr)
    %removing padded zeros if wavelength pair data sizes are different.
    Umkehr(i).data.SolarZenithAngle (Umkehr(i).data.SolarZenithAngle(:,:) == 0) = NaN;
    Umkehr(i).data.Nvalue (Umkehr(i).data.Nvalue(:,:) == 0) = NaN;
    Umkehr(i).data.Rvalue (Umkehr(i).data.Rvalue(:,:) == 0) = NaN;
    Umkehr(i).data.Time (Umkehr(i).data.Time(:,:) == 0) = NaN;
    Umkehr(i).data.SolarAzimuthAngle (Umkehr(i).data.SolarAzimuthAngle(:,:) == 0) = NaN;

    %removing data that is taken at a SZA that is above user limit.       
    Umkehr(i).data.Nvalue (Umkehr(i).data.SolarZenithAngle >= inputs.SZA_limit) = NaN;
    Umkehr(i).data.SolarZenithAngle (Umkehr(i).data.SolarZenithAngle >= inputs.SZA_limit) = NaN;
    
    %removing wavelength pairs that are not specified
    for j = 1:length(Umkehr(i).data.WaveLengthPair)    
        measWLP{j,1} = char(Umkehr(i).data.WaveLengthPair(j));          
    end
    WLPlocation = zeros(length(inputs.WLP_to_retrieve),1);
    for j = 1:length(inputs.WLP_to_retrieve)
        WLPmatch(j,1:length(measWLP)) = strcmp(inputs.WLP_to_retrieve(j), measWLP);
        if isempty(find(WLPmatch,1))
            disp(['No specified wavelengths exist for input file: ',allfiles(i).name,'.']);
            disp('Proceeding to next date.');            
            WLPlocation(j) = 0;
            Umkehr_remove(i) = i;        
        elseif ~isempty(find(WLPmatch(j,:),1))            
            WLPlocation(j) = find(WLPmatch(j,:));                         
            Umkehr_remove(i) = 0;
        else
            display([inputs.WLP_to_retrieve(j),' pair wavelengths do not exist for file: ',...
                allfiles(i).name]);
            disp('Proceeding to next date.');
            WLPlocation(j) = 0;
            Umkehr_remove(i) = i;        
        end
    end    
    WLPlocation (WLPlocation == 0) = [];
    if Umkehr_remove(i) == 0
        Umkehr(i).data.Nvalue = Umkehr(i).data.Nvalue(WLPlocation,:); 
        Umkehr(i).data.Rvalue = Umkehr(i).data.Rvalue(WLPlocation,:); 
        Umkehr(i).data.SolarZenithAngle = Umkehr(i).data.SolarZenithAngle(WLPlocation,:); 
        Umkehr(i).data.Time = Umkehr(i).data.Time(WLPlocation,:); 
        Umkehr(i).data.SolarAzimuthAngle = Umkehr(i).data.SolarAzimuthAngle(WLPlocation,:); 
        Umkehr(i).data.WaveLengthPair = Umkehr(i).data.WaveLengthPair(WLPlocation);
    end
    
    date = datevec(Umkehr(i).data.Time(1));
    if date(4) >= 12
        Umkehr(i).attributes.polarisation = 'Evening';
    else
        Umkehr(i).attributes.polarisation = 'Morning';
    end
    
    %converting missing data to NaNs
    Umkehr(i).data.Nvalue (Umkehr(i).data.Nvalue == -9999) = NaN;
    Umkehr(i).data.Rvalue (Umkehr(i).data.Rvalue == -9999) = NaN;
    Umkehr(i).data.SolarZenithAngle (Umkehr(i).data.SolarZenithAngle == -9999) = NaN;
    Umkehr(i).data.SolarAzimuthAngle (Umkehr(i).data.SolarAzimuthAngle == -9999) = NaN;
    Umkehr(i).data.Time (Umkehr(i).data.Time == -9999) = NaN;
    Umkehr(i).data.WaveLengthPair (Umkehr(i).data.WaveLengthPair == -9999) = NaN;
    clearvars measWLP WLPmatch
end
Umkehr_remove (Umkehr_remove == 0) = [];
Umkehr(Umkehr_remove) = [];

if inputs.plot_measurements
    plot_measurements(Umkehr,inputs);
end

end

