function [RMS] = createRMS(y,yhat)

a = reshape(y',1,numel(y))-reshape(yhat',1,numel(yhat));
RMS = sqrt(sum(a.^2)/length(a));

% figure;
% h = gcf; 
% set(h,'color','white','position',[100 100 900 700]);
% plot(RMS,'linewidth',2);
% set(gca,'xtick',0:1:15,'xticklabel',0:5:75,'fontsize',16);
% xlabel('Scale factor','fontsize',18);
% ylabel('RMS','fontsize',18);
% title('RMS of retrievals of A+C+D pair measurements for different Sa matrices (Se = Se*20)');


end