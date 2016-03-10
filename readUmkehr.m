function [Umkehr] = readUmkehr(inputs)

if ~isempty(inputs.daterange == 1)
    % individual measurement
    [Umkehr.info, Umkehr.data, Umkehr.attributes] = readnetcdf(strcat(...
        '../input/Umkehr/netcdftest/', inputs.station, '/', inputs.daterange(1:4),'/',...
        inputs.station, '_', inputs.daterange, '_', inputs.morn_or_even, '_',...
        'ACDPair','_Umkehr.nc'));
elseif ~isempty(inputs.daterange > 1)
    % range of measurements 
    
end

%removing padded zeros if wavelength pair data sizes are different.
for i = 1:length(Umkehr.data)
    Umkehr.data(i).SolarZenithAngle (Umkehr.data(i).SolarZenithAngle(:,:) == 0) = NaN;
    Umkehr.data(i).Nvalue (Umkehr.data(i).Nvalue(:,:) == 0) = NaN;
    Umkehr.data(i).Rvalue (Umkehr.data(i).Rvalue(:,:) == 0) = NaN;
    Umkehr.data(i).Time (Umkehr.data(i).Time(:,:) == 0) = NaN;
    Umkehr.data(i).SolarAzimuthAngle (Umkehr.data(i).SolarAzimuthAngle(:,:) == 0) = NaN;

    %removing data that is taken at a SZA that is above user limit.       
    Umkehr.data(i).Nvalue (Umkehr.data(i).SolarZenithAngle >= inputs.SZA_limit) = NaN;
    Umkehr.data(i).SolarZenithAngle (Umkehr.data(i).SolarZenithAngle >= inputs.SZA_limit) = NaN;
end

%removing wavelength pairs that are not specified
for i = 1:length(Umkehr.data.WLP)    
    measWLP{i,1} = char(Umkehr.data.WLP(i));          
end

WLPlocation = zeros(length(inputs.WLP_to_retrieve),1);
for i = 1:length(inputs.WLP_to_retrieve);
    WLPmatch = strcmp(inputs.WLP_to_retrieve(i), measWLP);    
    WLPlocation(i) = find(WLPmatch);
end

Umkehr.data.Nvalue = Umkehr.data.Nvalue(WLPlocation,:); 
Umkehr.data.Rvalue = Umkehr.data.Rvalue(WLPlocation,:); 
Umkehr.data.SolarZenithAngle = Umkehr.data.SolarZenithAngle(WLPlocation,:); 
Umkehr.data.Time = Umkehr.data.Time(WLPlocation,:); 
Umkehr.data.SolarAzimuthAngle = Umkehr.data.SolarAzimuthAngle(WLPlocation,:); 
Umkehr.data.WLP = Umkehr.data.WLP(WLPlocation);

end

