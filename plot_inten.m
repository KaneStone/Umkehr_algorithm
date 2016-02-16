function [] = plot_inten(intensity,atmos,sz)

addpath('/Users/kanestone/work/supportCode/cbrewer/cbrewer/cbrewer/');
addpath('/Users/kanestone/work/supportCode/exportFig');

%Intensity weighted curve
zi = 1:1:80;
scale_factor = 4;   
height_limit = 65;
font_size = 24;
for i = 1:2
    for j = 1:sz(2);
        a = squeeze(intensity(i,1:80,j));    
        a_weight(i,j) = sum(zi.*a)./sum(a);
        clearvars a
        int_weight(i,j) = interp1(zi,squeeze(intensity(i,1:80,j)),a_weight(i,j));
    end
end
int_weight(1,:) = int_weight(1,:)*scale_factor; 

%sample = [10,14,18,22,26,32,36]; %may cause problems if outside range of SZA
sample = [9, 14, 18, 21, 24, 30, 32];
[max_ind max_ozone] = max(atmos.ozone);

cbrew = cbrewer('seq','Oranges',7);

figure;
fig = gcf;
set(fig,'color','white','position',[100 100 1000 700]);

%plot longwavelength intensities
long_line = line(squeeze(intensity(2,1:height_limit,sample)),1:height_limit,...
    'LineWidth',3,'LineStyle','--');%'color',[0 .6 0]);
haxes1 = gca;
set(haxes1,'XColor','k','YColor','k');
hold on

%plot short wavelength intensities
short_line = plot(squeeze(intensity(1,1:height_limit,sample))*scale_factor,...
    1:height_limit,'LineWidth',3);

%plot weighted intensitie heights
iwh1 = plot(int_weight(1,sample)',a_weight(1,sample)','-o','color',[0 0 0],...
    'LineWidth',4);
%iwh1 = scatter(int_weight(1,sample)',a_weight(1,sample)','o','k','filled');

iwh2 = plot(int_weight(2,sample)',a_weight(2,sample)','--o','color',[0 0 0],...
'LineWidth',4);
%iwh2 = scatter(int_weight(2,sample)',a_weight(2,sample)','o','k','filled');

ylim([0 60]);

ylabel('Altitude (km)','fontsize',font_size);
xlabel('Intensity','fontsize',font_size);
set(gca,'fontsize',font_size-2);
haxes1_pos = get(haxes1,'Position');
haxes2 = axes('Position',haxes1_pos,...
              'XAxisLocation','top',...
              'YAxisLocation','right',...
              'Color','none');
set(haxes2,'XColor',[.5 .5 .5],'YColor',[.5 .5 .5]);
xlim([0 1e13]);
ylim([0 60]);
%plot ozone profile
po = line(atmos.ozone(1:height_limit),1:height_limit,'Parent',haxes2,...
    'LineWidth',3,'color',[.5 .5 .5]);
hline = refline(0,max_ozone);
set(hline,'Color',[.5 .5 .5],'LineWidth',3,'LineStyle','-.');

set(gca, 'xdir','reverse','xtick',0:1e12:6e12,'xticklabel',0:1:6....
    ,'fontsize',font_size,'ytick',[])

xlabel('Ozone number density (\times 10^{12} molecules/cm^3)','fontsize',font_size);
%set(gcf,'position',[100 100 1000 700]);

%SETTING UP LEGEND
sl = length(sample);
for i = 1:sl
    if i ~= sl;
        C{i,:} = strcat(num2str(round(atmos.true_actual(sample(i)))),'$^{\circ}$');
    else C{i,:} = strcat(num2str(round(atmos.true_actual(sample(i)))),'$^{\circ}$');
    end
end
C{sl+1,:} = '$\bar{I_{\lambda1}}$';%
C{sl+2,:} = '$\bar{I_{\lambda2}}$';
C{sl+3,:} = 'Ozone profile';
C{sl+4,:} = 'Ozone maximum';
h = legend([short_line; iwh1; iwh2; po; hline],C,'Orientation','horizontal');
%legend('Ozone profile','Ozone peak','boxoff');
rect = [0.75, -.01, .05, .05];
set(h, 'Position', rect,'box','off');
set(h,'interpreter','Latex','FontSize',font_size-12);
set(h,'FontName','Helvetica');
psn=get(h,'Position');
psn(3)=0.6*psn(3);
set(h,'position',psn);

%set(fig, 'PaperPositionMode', 'manual');
%set(fig, 'PaperUnits', 'inches');
%set(fig, 'PaperPosition', [2.5 2.5 12 10]);

%legend([long_line short_line hline], num2str(ceil(atmos.true_actual(sample))')...
%    ,num2str(ceil(atmos.true_actual(sample))'),'ozone profile');
file = '/Users/kanestone/work/Dobson/OUTPUT/plots/IntensityContributionsDpair.pdf';
export_fig(fig,file,'-pdf','-nocrop')
%print(fig,'-depsc2','-r200','-loose',file);
end