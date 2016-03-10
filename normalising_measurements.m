function [atmos, Umkehr] = normalising_measurements(atmos,Umkehr,inputs,theta,measurement_number)
%Normalising measurements to lowest SZA

Umkehrdate = datevec(Umkehr.data.Time);
hourmin = min(Umkehrdate(:,4));

if hourmin < 12
    Umkehr.data.Nvalue = fliplr(Umkehr.data.Nvalue);
    Umkehr.data.SolarZenithAngle  = fliplr(Umkehr.data.SolarZenithAngle);
end
for j = 1:size(Umkehr.data.SolarZenithAngle,1);
    if size(Umkehr.data.SolarZenithAngle,1) > 1 && j == 1
        [~,b] = min(Umkehr.data.SolarZenithAngle(j,:));
        atmos.normalisationindex(j) = b;
    elseif size(Umkehr.data.SolarZenithAngle,1) > 1 && j == 3
        [~,b] = min(Umkehr.data.SolarZenithAngle(j,:));
        atmos.normalisationindex(j) = b;
    else
        theta1 = min(Umkehr.data.SolarZenithAngle(j,:)):2.5:max(Umkehr.data.SolarZenithAngle(j,:));

        splfit = splinefit(Umkehr.data.SolarZenithAngle(j,:),Umkehr.data.Nvalue(j,:),length(theta1)-1,3,'r');
        spliney = ppval(splfit,theta1);
        final = interp1(theta1,spliney,Umkehr.data.SolarZenithAngle(j,:),'linear','extrap');
        [~, atmos.normalisationindex(j)] = min(abs(final(theta1 < theta1(1)+10) - ...
            Umkehr.data.Nvalue(j,theta1 < theta1(1)+10)));
    end

    
    if inputs.designated_SZA
    %next two lines only work for C_pair
        Umkehr.data.Nvalues (isnan(Umkehr.data.Nvalues)) = [];
        Umkehr.data.SolarZenithAngle (isnan(Umkehr.data.SolarZenithAngle)) = [];
        Umkehr.data.Nvalues = interp1(Umkehr.data.SolarZenithAngle,...
            Umkehr.data.Nvalues,theta,'linear','extrap');
        Umkehr.data.SolarZenithAngle = theta;
        atmos.normalisationindex = 1;
        Umkehr.data.Nvalues = Umkehr.data.Nvalues - repmat(Umkehr.data.Nvalues(1),1,13);
        return
    end
    
%     figure;
%     set(gcf,'color','white','position',[100 100 1000 700]);
%     
%     plot(atmos.initial_SZA(measurement_number).SZA(j,:),atmos.N_values(measurement_number).N(j,:),'-x','LineWidth',2,'MarkerSize',10);
%     hold on
%     plot(atmos.initial_SZA(measurement_number).SZA(j,:),final,'LineWidth',2);
%     set(gca,'fontsize',20)
%     xlabel('SZA','fontsize',20)
%     ylabel('N-value','fontsize',20)
%     title('spline fit to data','fontsize',20);
%     lh = legend('measurements','spline');
%     set(lh,'fontsize',20,'location','NorthWest','box','off');
%     export_fig('/Users/stonek/Dropbox/Work_Share/Dobson_Umkehr/Figures/splinefitfornormalisation.png','-png');
%     export_fig('/Users/stonek/Dropbox/Work_Share/Dobson_Umkehr/Figures/splinefitfornormalisation.pdf','-pdf');
    %for i = 1:length(atmos.N_values);
    sz = size(Umkehr.data.Nvalue(j,:));
    %[~, SZA_min_location] = min(atmos.initial_SZA(i).SZA,[],2);

    N_norm = Umkehr.data.Nvalue(j,atmos.normalisationindex(j));
    Umkehr.data.Nvalue(j,:) = Umkehr.data.Nvalue(j,:) - repmat(N_norm,1,sz(2));  
    clearvars theta1
end
%end

end
