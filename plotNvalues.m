function [] = plotNvalues(Apparent,N)

figure;
fig  = gcf;
set(fig,'color','white','Position',[100 100 1000 700]);

y = plot(Apparent,N);

set(y,'linewidth',2,'marker','s','markersize',10)
legend('A pair','C pair','D pair','Location','NorthWest');

set(gca,'fontsize',18);
xlabel('SZA','fontsize',18);
ylabel('N value','fontsize',18);
title('Forward Model','fontsize',20);

x_min = floor(min(Apparent));
x_max = ceil(max(Apparent));
y_min = floor(min(N)-min(N)/10);
y_max = floor(max(N)+max(N)/10);

axis([x_min x_max y_min y_max]);

%set(fig, 'PaperPositionMode','auto');
%print('-dpng','-r0', strcat('/Users/stonek/work/Dobson/plots','N_value.png'));

end