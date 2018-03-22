function [] = print_diagnostics(figs,AK,setup,WLP,inputs,foldersandnames)

WLP = char(WLP');
date = setup.atmos.Umkehrdate;
datetoprint = [num2str(date(1)),sprintf('%02d',date(2)),sprintf('%02d',date(3))];
if strcmp(inputs.seasonal, 'constant')
    WLP = 'C_CAP';
end

output_folder = strcat(foldersandnames.diagnostics,inputs.station,'/');
filename = strcat(inputs.station,'_',WLP,'pair_',datetoprint,foldersandnames.name_ext);
file = (strcat(output_folder,filename));
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

%% 
export_fig(file,figs.fig1,'-pdf','-nocrop');
export_fig(file,figs.fig4,'-pdf','-nocrop','-append');
export_fig(file,figs.fig2,'-pdf','-nocrop','-append');
export_fig(file,figs.fig3,'-pdf','-nocrop','-append');

%%
figure;
set(gcf, 'Visible', 'off')
fig3 = gcf;
set(fig3,'color','white','Position',[100 100 1000 700]);
plot(AK.AK',1:length(AK.AK),'LineWidth',2);
hold on
set(gca,'fontsize',18);
ylabel('Altitude (km)','fontsize',20);
xlabel('AK','fontsize',20);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);
export_fig(file,fig3,'-pdf','-nocrop','-append');

%%
figure;
set(gcf, 'Visible', 'off')
fig4 = gcf;
set(fig4,'color','white','Position',[100 100 1000 700]);
plot(AK.area',1:length(AK.AK),'LineWidth',2);
hold on
ylabel('Altitude (km)','fontsize',20);
xlabel('Area of AK','fontsize',20);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','Area of AK'),'fontsize',24);
export_fig(file,fig4,'-pdf','-nocrop','-append');

%%
AK.resolution (AK.resolution > 100) = 100;
AK.resolution (AK.resolution < 0) = 100;

figure;
set(gcf, 'Visible', 'off')
fig5 = gcf;
set(fig5,'color','white','Position',[100 100 1000 700]);
plot(AK.resolution',1:length(AK.AK),'LineWidth',2);
hold on
annotation('textbox',[.15 .8 .5 .1],...
    'String',{['Degrees of freedom = ' num2str(AK.dof)]},...
    'fontsize',24,...
    'EdgeColor','white')

ylabel('Altitude (km)','fontsize',20);
xlabel('1/diag(AK) (km)','fontsize',20);
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','resolution'),'fontsize',24);
export_fig(file,fig5,'-pdf','-nocrop','-append');

%%
figure;
set(gcf, 'Visible', 'off')
fig7 = gcf;
set(fig7,'color','white','Position',[100 100 1000 700]);
plot(AK.AK2(:,1:8)',1:length(AK.AK2),'LineWidth',2);
hold on
xlim([-.2 .9]);
ylabel('Layer No.','fontsize',20);
xlabel('AK','fontsize',20);
set(gca,'fontsize',18);
set(gca,'yticklabel',{'0+1','2+3','4','5','6','7','8','9+'});
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);
export_fig(file,fig7,'-pdf','-nocrop','-append');
end