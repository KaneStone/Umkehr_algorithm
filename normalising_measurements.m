function [atmos,Umkehr,theta] = normalising_measurements(atmos,Umkehr,inputs,theta)

%Normalising measurements to appropriate SZA

Umkehrdate = datevec(Umkehr.data.Time);
hourmin = min(Umkehrdate(:,4));
if hourmin < 11
    Umkehr.data.Nvalue = fliplr(Umkehr.data.Nvalue);
    Umkehr.data.SolarZenithAngle  = fliplr(Umkehr.data.SolarZenithAngle);
end

if inputs.designated_SZA
    splineNvalue = zeros(length(Umkehr.data.WLP),length(theta));
    for j = 1:size(Umkehr.data.SolarZenithAngle,1);
        minSZA = min(Umkehr.data.SolarZenithAngle(j,:));
        if minSZA > 75
            error(['designated N-values have not been calculated from ',...
                char(Umkehr.data.WLP(j)),' pair wavelength data. Minumum SZA of ',...
                num2str(minSZA),' is to large.']);
        end
        spline = splinefit(Umkehr.data.SolarZenithAngle(j,:),Umkehr.data.Nvalue(j,:),...
            length(theta),3,'r');
        splineNvalue(j,:) = ppval(spline,theta);        
        atmos.normalisationindex(j) = 1;        
    end
    Umkehr.data.Nvalue = splineNvalue;
    Umkehr.data.SolarZenithAngle = repmat(theta,length(Umkehr.data.WLP),1);
    if strcmp(inputs.normalise,'no') 
        return
    else
        Umkehr.data.Nvalue = Umkehr.data.Nvalue - repmat(Umkehr.data.Nvalue(:,1),1,13);        
        return
    end
end   

if strcmp(inputs.normalise,'no') 
    return
end

splinestep = 1;

for j = 1:size(Umkehr.data.SolarZenithAngle,1);
    switch inputs.normalise
        case 'lowest'            
            [~,lowest_index] = min(Umkehr.data.SolarZenithAngle(j,:));
            atmos.normalisationindex(j) = lowest_index;
        case 'cloudflag'
            %construct spline and calculate closest fit within range
            splinetheta = min(Umkehr.data.SolarZenithAngle(j,2:end-1)):splinestep:...
                max(Umkehr.data.SolarZenithAngle(j,2:end-1));            
            spline = splinefit(Umkehr.data.SolarZenithAngle(j,:),Umkehr.data.Nvalue(j,:),...
                length(splinetheta),3);
            splineNvalue = ppval(spline,splinetheta);                                                
            final = interp1(splinetheta,splineNvalue,Umkehr.data.SolarZenithAngle(j,:),...
                'linear','extrap');                               
            normalisation_range = (max(Umkehr.data.SolarZenithAngle(j,:)) - ...
                min(Umkehr.data.SolarZenithAngle(j,:))) / 3;                       
            realindex = find(Umkehr.data.SolarZenithAngle(j,:) < ...
                min(Umkehr.data.SolarZenithAngle(j,:)) + normalisation_range);        
            [~,subindex] = min(abs(final(realindex) - Umkehr.data.Nvalue(j,realindex)));                
            atmos.normalisationindex(j) = realindex(subindex);
            [~,subindex2] = min(abs(final(realindex) - Umkehr.data.Nvalue(j,realindex)));                
            atmos.normalisationindex(j) = realindex(subindex);            
    end        
    
    Nvaluesize = size(Umkehr.data.Nvalue(j,:));    
    Nvalue_norm = Umkehr.data.Nvalue(j,atmos.normalisationindex(j));
    Umkehr.data.Nvalue(j,:) = Umkehr.data.Nvalue(j,:) - repmat(Nvalue_norm,1,Nvaluesize(2));      
end

end
