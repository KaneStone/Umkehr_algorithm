function [] = print_diagnostics(x,y,z,AK,station,extra,measurement_number,L_ozone)%,AK,station,year,test)

date = extra.atmos.date(measurement_number).date;
WLP = extra.atmos.N_values(measurement_number).WLP;

if L_ozone
    file = strcat('/Users/stonek/work/Dobson/OUTPUT/plots/diagnostics/',...
    station,'/',station,'_',WLP,'_',num2str(date(3)),'-',num2str(date(2))...
    ,'-',num2str(date(1)),'.ps');
else
    file = strcat('/Users/stonek/work/Dobson/OUTPUT/plots/diagnostics/aerosols/',...
    station,'/',station,'_',WLP,'_',num2str(date(3)),'-',num2str(date(2))...
    ,'-',num2str(date(1)),'.ps');
end

print(x,'-dpsc2','-r200',file);
print(z,'-dpsc2','-r200',file,'-append');
print(y,'-dpsc2','-r200',file,'-append');

figure;
set(gcf, 'Visible', 'off')
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

print(fig3,'-dpsc2','-r200',file,'-append');

figure;
set(gcf, 'Visible', 'off')
fig4 = gcf;
set(fig4,'color','white','Position',[100 100 1000 700]);
plot(AK.area',1:length(AK.AK),'LineWidth',2);
hold on
ylabel('Altitude (km)','fontsize',20);
xlabel('Area of AK','fontsize',20);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Area of AK'),'fontsize',24);
print(fig4,'-dpsc2','-r200',file,'-append');

AK.resolution (AK.resolution > 100) = 100;

figure;
set(gcf, 'Visible', 'off')
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

print(fig5,'-dpsc2','-r200',file,'-append');

figure;
set(gcf, 'Visible', 'off')
fig6 = gcf;
set(fig6,'color','white','Position',[100 100 1000 700]);
plot(AK.AK1(:,1:16)'/5,1:length(AK.AK1),'LineWidth',2);
hold on
%plot(extra.atmos.true_actual',N_val','LineWidth',2);
% annotation('textbox',[.6 .25 .25 .1],...
%     'String',{['Degrees of freedom = ' num2str(AK.dof1)]},...
%     'fontsize',12,...
%     'EdgeColor','white')
xlim([-.2 .9]);
ylabel('Layer No.','fontsize',20);
xlabel('AK','fontsize',20);
set(gca,'fontsize',18);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);

print(fig6,'-dpsc2','-r200',file,'-append');

end