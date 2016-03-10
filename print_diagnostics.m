function [] = print_diagnostics(x,y,z,AK,setup,inputs,foldersandnames)

date = setup.atmos.Umkehrdate;

if strcmp(inputs.seasonal, 'constant');
    WLP = 'C_CAP';
else WLP = inputs.WLP_to_retrieve;
end

output_folder = strcat(foldersandnames.diagnostics,inputs.station,'/');
file_name = strcat(inputs.station,'_',WLP,'_',sprintf('%d',date(3)),'-',...
    sprintf('%02d',date(2)),'-',sprintf('%02d',date(1)),foldersandnames.name_ext);
file = (strcat(output_folder,file_name));
if ~exist(output_folder,'dir');
    mkdir(output_folder);
end


%-------------------------
export_fig(file,x,'-pdf','-nocrop');
export_fig(file,z,'-pdf','-nocrop','-append');
export_fig(file,y,'-pdf','-nocrop','-append');

%-------------------------
figure;
set(gcf, 'Visible', 'off')
fig3 = gcf;
set(fig3,'color','white','Position',[100 100 1000 700]);
plot(AK.AK',1:length(AK.AK),'LineWidth',2);
hold on
set(gca,'fontsize',18);
ylabel('Altitude (km)','fontsize',20);
xlabel('AK','fontsize',20);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);
export_fig(file,fig3,'-pdf','-nocrop','-append');
%-------------------------
figure;
set(gcf, 'Visible', 'off')
fig4 = gcf;
set(fig4,'color','white','Position',[100 100 1000 700]);
plot(AK.area',1:length(AK.AK),'LineWidth',2);
hold on
ylabel('Altitude (km)','fontsize',20);
xlabel('Area of AK','fontsize',20);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Area of AK'),'fontsize',24);
export_fig(file,fig4,'-pdf','-nocrop','-append');
%-------------------------
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
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','resolution'),'fontsize',24);
export_fig(file,fig5,'-pdf','-nocrop','-append');
%-------------------------
figure;
set(gcf, 'Visible', 'off')
fig6 = gcf;
set(fig6,'color','white','Position',[100 100 1000 700]);
plot(AK.AK1(:,1:16)'/5,1:length(AK.AK1),'LineWidth',2);
hold on
xlim([-.2 .9]);
ylabel('Layer No.','fontsize',20);
xlabel('AK','fontsize',20);
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);
export_fig(file,fig6,'-pdf','-nocrop','-append');
%-------------------------
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
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Averaging Kernel'),'fontsize',24);
export_fig(file,fig7,'-pdf','-nocrop','-append');
end