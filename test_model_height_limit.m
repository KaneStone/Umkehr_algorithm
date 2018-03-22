function [] = test_model_height_limit(intensity,trueSZA)

if ~exist('../output/diagnostics/other/','dir')
    mkdir('../output/diagnostics/other/');
end

zi = 1:size(intensity,2);
for i = 1:2
    for j = 1:size(intensity,3);
        a = squeeze(intensity(i,:,j));    
        a_weight(i,j) = sum(zi.*a)./sum(a);
        clearvars a
        int_weight(i,j) = interp1(zi,squeeze(intensity(i,:,j)),a_weight(i,j));
    end
end

figure;
fig1 = gcf;
set(fig1,'color','white','Position',[100 100 1000 700],'Visible','off');
plot(trueSZA,squeeze(a_weight(1,:)),'o-','LineWidth',2);
hold on
plot(trueSZA,squeeze(a_weight(2,:)),'ro-','LineWidth',2);
set(gca,'fontsize',18);
xlabel('SZA','fontsize',20);
ylabel('Altitude','fontsize',20);
title('Altitude of maximum scattering intensity','fontsize',22);
lh  = legend('Short wavelength','Long wavelength','location','NorthWest');
set(lh,'box','off');
filename = ['../output/diagnostics/other/altMaxScatInt_',num2str(size(intensity,2)),'km.pdf'];
export_fig(fig1,filename,'-pdf');

figure;
fig2 = gcf;
set(fig2,'color','white','Position',[100 100 1000 700],'Visible','off');
plot(trueSZA,squeeze(int_weight(1,:)),'o-','LineWidth',2);
hold on
plot(trueSZA,squeeze(int_weight(2,:)),'ro-','LineWidth',2);
set(gca,'fontsize',18);
xlabel('SZA','fontsize',20);
ylabel('Maximum intensity','fontsize',20);
title('Value of maximum scattering intensity','fontsize',22);
lh2 = legend('Short wavelength','Long wavelength');
set(lh2,'box','off');
filename = ['../output/diagnostics/other/MaxScatInt_',num2str(size(intensity,2)),'km.pdf'];
export_fig(fig2,filename,'-pdf');

close all

end