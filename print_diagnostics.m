function [] = print_diagnostics(x,y,AK,station,extra,measurement_number)%,AK,station,year,test)

date = extra.atmos.date(measurement_number).date;
WLP = extra.atmos.N_values(measurement_number).WLP;

print(x,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
station,'/',station,'_',WLP,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'));

print(y,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
station,'/',station,'_',WLP,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'),'-append');

figure;
fig3 = gcf;
set(fig3,'color','white','Position',[100 100 1000 700]);
plot(AK.AK',1:length(AK.AK),'LineWidth',2);
hold on
%plot(extra.atmos.true_actual',N_val','LineWidth',2);
set(gca,'fontsize',18);
ylabel('Altitude (km)','fontsize',20);
xlabel('AK','fontsize',20);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);
%print(fig3,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
%station,'/',station,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'),'-append');

print(fig3,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
station,'/',station,'_',WLP,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'),'-append');

figure;
fig4 = gcf;
set(fig4,'color','white','Position',[100 100 1000 700]);
plot(AK.area',1:length(AK.AK),'LineWidth',2);
hold on
ylabel('Altitude (km)','fontsize',20);
xlabel('Area of AK','fontsize',20);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Area of AK'),'fontsize',24);
print(fig4,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
station,'/',station,'_',WLP,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'),'-append');

AK.resolution (AK.resolution > 100) = 100;

figure;
fig5 = gcf;
set(fig5,'color','white','Position',[100 100 1000 700]);
plot(AK.resolution',1:length(AK.AK),'LineWidth',2);
hold on
%plot(extra.atmos.true_actual',N_val','LineWidth',2);
annotation('textbox',[.6 .25 .25 .1],...
    'String',{['Degrees of freedom = ' num2str(AK.dof)]},...
    'fontsize',12,...
    'EdgeColor','white')

ylabel('Altitude (km)','fontsize',20);
xlabel('1/diag(AK) (km)','fontsize',20);
set(gca,'fontsize',18);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','resolution'),'fontsize',24);
%print(fig5,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
%station,'/',station,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'),'-append');

print(fig5,'-dpsc2','-r200',strcat('/Users/stonek/work/Dobson/plots/diagnostics/',...
station,'/',station,'_',WLP,'_',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),'.ps'),'-append');

end