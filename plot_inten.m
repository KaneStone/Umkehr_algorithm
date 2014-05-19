function [] = plot_inten(intensity,atmos,sz)

%Intensity weighted curve
zi = 1:1:80;
scale_factor = 9;   
for i = 1:2
    for j = 1:sz(2);
        a = squeeze(intensity(i,1:80,j));    
        a_weight(i,j) = sum(zi.*a)./sum(a);
        clearvars a
        int_weight(i,j) = interp1(zi,squeeze(intensity(i,1:80,j)),a_weight(i,j));
    end
end
int_weight(1,:) = int_weight(1,:)*scale_factor; 

%sample = (10:4:32);
sample = [10,14,18,22,26,32];
[max_ind max_ozone] = max(atmos.ozone);

figure;
fig = gcf;
set(fig,'color','white');%,'position',[100 100 1000 700]);

%plot longwavelength intensities
long_line = line(squeeze(intensity(2,1:50,sample)),1:50,'LineWidth',3,'LineStyle','--');%'color',[0 .6 0]);
haxes1 = gca;
set(haxes1,'XColor','k','YColor','k');
hold on

%plot short wavelength intensities
short_line = plot(squeeze(intensity(1,1:50,sample))*scale_factor,1:50,'LineWidth',3);

%plot weighted intensitie heights
iwh1 = plot(int_weight(1,sample)',a_weight(1,sample)','-o','color',[0 0 0],'LineWidth',4);
iwh2 = plot(int_weight(2,sample)',a_weight(2,sample)','--o','color',[0 0 0],'LineWidth',4);
%legend('75','80','83','85','87','90','\lambda_1 intensity weighted height',...
%    '\lambda_1 intensity weighted height');
ylabel('Altitude (km)','fontsize',10);
xlabel('Intensity','fontsize',10);
set(gca,'fontsize',10);
haxes1_pos = get(haxes1,'Position');
haxes2 = axes('Position',haxes1_pos,...
              'XAxisLocation','top',...
              'YAxisLocation','right',...
              'Color','none');
set(haxes2,'XColor',[.5 .5 .5],'YColor',[.5 .5 .5]);
%set(haxes2,'XColor','k','YColor','k');
xlim([0 1e13]);
%plot ozone profile
po = line(atmos.ozone(1:50),1:50,'Parent',haxes2,'LineWidth',3,'color',[.5 .5 .5]);
hline = refline(0,max_ozone);
set(hline,'Color',[.5 .5 .5],'LineWidth',4,'LineStyle','-.');
%hline = refline(0,max_ozone);
%uistack(hline, 'bottom')
%set(hline,'Color',[.4 .4 .4],'LineWidth',1.5);
%set(h_2, 'OuterPosition',[100 100 1000 700]);

set(gca, 'xdir','reverse','xtick',0:1e12:6e12,'xticklabel',0:1:6....
    ,'fontsize',10,'ytick',[])

%For diagnostics
% xlabel('SZA','fontsize',18);

xlabel('Ozone number density (\times 10^{12} molecules/cm^3)','fontsize',10);
file = '/Users/stonek/work/Dobson/OUTPUT/inten.eps';
set(gcf,'position',[100 100 1000 700]);
%set(gcf,'PaperPosition',[100, 100, 1000, 700])

%SETTING UP LEGEND
sl = length(sample);
for i = 1:sl
    if i ~= sl;
        C{i,:} = strcat(num2str(ceil(atmos.true_actual(sample(i)))),'$^{\circ}$');
    else C{i,:} = strcat(num2str(ceil(atmos.true_actual(sample(i)))),'$^{\circ}$');
    end
end
C{sl+1,:} = '$\bar{I_{\lambda1}}$';%
C{sl+2,:} = '$\bar{I_{\lambda2}}$';
C{sl+3,:} = 'Ozone profile';
C{sl+4,:} = 'Ozone maximum';
h = legend([short_line; iwh1; iwh2; po; hline],C,'Orientation','horizontal');
%legend('Ozone profile','Ozone peak','boxoff');
legend boxoff
rect = [0.75, -.01, .05, .05];
set(h, 'Position', rect);
set(h,'interpreter','Latex','FontSize',14);
set(h,'FontName','Helvetica');
psn=get(h,'Position');
psn(3)=0.4*psn(3);
set(h,'position',psn);

set(fig, 'PaperPositionMode', 'manual');
set(fig, 'PaperUnits', 'inches');
set(fig, 'PaperPosition', [2.5 2.5 12 10]);

%legend([long_line short_line hline], num2str(ceil(atmos.true_actual(sample))')...
%    ,num2str(ceil(atmos.true_actual(sample))'),'ozone profile');

print(fig,'-depsc2','-r200','-loose',file);