function [] = plot_measurements(atmos_init,theta,station,measurement_number,Just_C);

atmos = atmos_init;

% designated interpolation
%next two lines only work for C_pair

%atmos.N_values(measurement_number).N (isnan(atmos.N_values(measurement_number).N)) = [];
%atmos.initial_SZA(measurement_number).SZA (isnan(atmos.initial_SZA(measurement_number).SZA)) = [];
%Apair = interp1(atmos.initial_SZA(measurement_number).SZA(1,:),...
%    atmos.N_values(measurement_number).N(1,:),theta,'linear','extrap');
Cpair = interp1(atmos.initial_SZA(measurement_number).SZA(2,:),...
    atmos.N_values(measurement_number).N(2,:),theta,'linear','extrap');
%Dpair = interp1(atmos.initial_SZA(measurement_number).SZA(3,:),...
%    atmos.N_values(measurement_number).N(3,:),theta,'linear','extrap');
cbrew = cbrewer('qual','Set1',3);
%plotting
lwidth = 3;
figure;
fig = gcf;
set(fig,'color','white','position',[100 100 900 700],'Visible','off');

if ~Just_C
    ap = plot(atmos.initial_SZA(measurement_number).SZA(1,:),atmos.N_values(measurement_number).N(1,:),...
        '-o','color',cbrew(:,1),'MarkerSize',10,'LineWidth',lwidth);
    hold on
    cp = plot(atmos.initial_SZA(measurement_number).SZA(2,:),atmos.N_values(measurement_number).N(2,:),...
        '-o','color',cbrew(:,2),'MarkerSize',10,'LineWidth',lwidth);

    dp = plot(atmos.initial_SZA(measurement_number).SZA(3,:),atmos.N_values(measurement_number).N(3,:),...
        '-o','color',cbrew(:,3),'MarkerSize',10,'LineWidth',lwidth);

    desp = plot(theta,Cpair,'-s','color','k','MarkerSize',10,'MarkerFaceColor','k','LineWidth',lwidth);
    axis([59 97 0 190])
    title(strcat(sprintf('%02d',atmos_init.date(1,21).date(1)),'-',sprintf('%02d',atmos_init.date(1,21).date(2)),...
        '-',num2str(atmos_init.date(1,21).date(3)),' Melbourne Umkehr'),'fontsize',32);
    lh = legend([ap,cp,dp,desp],'A-pair','C-pair','D-pair','Designated');
    set(lh,'location','NorthWest','fontsize',30,'box','off');
    
    filename = '/Users/stonek/Dropbox/Work_Share/Dobson_Umkehr/Figures/ACD_and_designated.pdf';
else
    
    plot(atmos.initial_SZA(measurement_number).SZA(2,:),atmos.N_values(measurement_number).N(2,:),...
        '-o','color',cbrew(:,2),'MarkerSize',10,'LineWidth',lwidth);
    
    axis([59 97 30 140])
    
    title(strcat(sprintf('%02d',atmos_init.date(1,21).date(1)),'-',sprintf('%02d',atmos_init.date(1,21).date(2)),...
        '-',num2str(atmos_init.date(1,21).date(3)),' Melbourne C-pair Umkehr'),'fontsize',32);
    
    filename = '/Users/stonek/Dropbox/Work_Share/Dobson_Umkehr/Figures/Cpair.pdf';
end


set(gca,'fontsize',26)
ylabel('N-value','fontsize',30)
xlabel('Solar zenith angle (degrees)','fontsize',30)

export_fig(filename,'-pdf');
close all

end