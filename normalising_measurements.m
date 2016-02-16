function [atmos] = normalising_measurements(atmos,designated_SZA,theta,measurement_number)
%Normalising measurements to lowest SZA


if atmos.hour_min(measurement_number) < 12
    atmos.N_values(measurement_number).N = fliplr(atmos.N_values(measurement_number).N);
    atmos.initial_SZA(measurement_number).SZA = fliplr(atmos.initial_SZA(measurement_number).SZA);
end
for j = 1:size(atmos.initial_SZA(measurement_number).SZA,1);
    if size(atmos.initial_SZA(measurement_number).SZA,1) > 1 && j == 1
        [~,b] = min(atmos.initial_SZA(measurement_number).SZA(j,:));
        atmos.normalisationindex(j) = b;
    elseif size(atmos.initial_SZA(measurement_number).SZA,1) > 1 && j == 3
        [~,b] = min(atmos.initial_SZA(measurement_number).SZA(j,:));
        atmos.normalisationindex(j) = b;
    else
        theta1 = min(atmos.initial_SZA(measurement_number).SZA(j,:)):2.5:max(atmos.initial_SZA(measurement_number).SZA(j,:));

        splfit = splinefit(atmos.initial_SZA(measurement_number).SZA(j,:),atmos.N_values(measurement_number).N(j,:),length(theta1)-1,3,'r');
        spliney = ppval(splfit,theta1);
        final = interp1(theta1,spliney,atmos.initial_SZA(measurement_number).SZA(j,:),'linear','extrap');
        [~, atmos.normalisationindex(j)] = min(abs(final(theta1 < theta1(1)+10) - atmos.N_values(measurement_number).N(j,theta1 < theta1(1)+10)));
    end

    
    if designated_SZA
    %next two lines only work for C_pair
    atmos.N_values(measurement_number).N (isnan(atmos.N_values(measurement_number).N)) = [];
    atmos.initial_SZA(measurement_number).SZA (isnan(atmos.initial_SZA(measurement_number).SZA)) = [];
    atmos.N_values(measurement_number).N = interp1(atmos.initial_SZA(measurement_number).SZA,...
        atmos.N_values(measurement_number).N,theta,'linear','extrap');
    atmos.initial_SZA(measurement_number).SZA = theta;
    atmos.normalisationindex = 1;
    atmos.N_values(measurement_number).N = atmos.N_values(measurement_number).N - repmat(atmos.N_values(measurement_number).N(1),1,13);
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
    sz = size(atmos.N_values(measurement_number).N(j,:));
    %[~, SZA_min_location] = min(atmos.initial_SZA(i).SZA,[],2);

    N_norm = atmos.N_values(measurement_number).N(j,atmos.normalisationindex(j));
    atmos.N_values(measurement_number).N(j,:) = atmos.N_values(measurement_number).N(j,:) - repmat(N_norm,1,sz(2));  
    clearvars theta1
end
%end

end
