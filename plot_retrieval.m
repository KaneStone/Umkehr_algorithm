function [fig1 fig2] = plot_retrieval(N,yhat,extra,xhat,Se,Sa,test,yhat1,station,date)



figure;
fig1 = gcf;
set(fig1,'color','white','Position',[100 100 1000 700]);
plot(xhat,1:61,'r','LineWidth',2)
hold on
addpath('/Users/stonek/work/Dobson/data_code');
herrorbar(extra.atmos.ozone,1:61,(diag(Sa)./5e3).^.5);
plot(extra.atmos.ozone,1:61,'LineWidth',2);
set(fig1,'color','white');
ylabel('Altitude','fontsize',20);
xlabel('number density','fontsize',20);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Ozone Profile'),'fontsize',24);
legend('retrieval','A prioir','location','NorthWest');

%set(fig1, 'PaperPositionMode','auto');
%print('-dpng','-r0', strcat('/Users/stonek/work/Dobson/plots/retrievals/Initial/','Macquarie_profile_',num2str(test),'.png'));

N_val = extra.atmos.N_values(test).N;
%N_val = load('Ret_as_Meas');
N_val (isnan(N_val)) = [];

error = (diag(Se)).^.5;
error = reshape(error,fliplr(size(N_val)));

figure;
fig2 = gcf;
set(fig2,'color','white','Position',[100 100 1000 700]);
plot(extra.atmos.true_actual',yhat','LineWidth',2);
hold on
%plot(extra.atmos.true_actual',N_val','LineWidth',2);
errorbar(extra.atmos.true_actual',N_val',error,'LineWidth',1.5,'LineStyle','--','color','black');
plot(extra.atmos.true_actual',(N_val-yhat)');
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','N Values'),'fontsize',24);
%legend('retrieval','measurement','location','NorthWest');
if strcmp(extra.atmos.N_values(test).WLP,'ACD')
    legend('Retrieval - A pair','Retrieval - C pair','Retrieval - D pair',...
        'Measurement - A pair','Measurement - C pair','Measurement - D pair',...
        'y-yhat','y-yhat','y-yhat','location','NorthWest');
elseif strcmp(extra.atmos.N_values(test).WLP,'C')
    legend('Retrieval - C pair','measurement','y-yhat','location','NorthWest');
end

% yhat2 = vertcat(yhat1.a)';
% sz_yhat1 = size(yhat1);
% figure;
% fig = gcf;
% set(fig,'color','white','Position',[100 100 1000 700]);
% plot(repmat(extra.atmos.true_actual,sz_yhat1(2),1)',yhat2,'LineWidth',2);
% hold on
% errorbar(extra.atmos.true_actual',N_val',error,'LineWidth',2,'color','black','LineStyle','--');
% ylabel('N-Value','fontsize',20);
% xlabel('SZA','fontsize',20);
% title('Macquarie N-values','fontsize',24);
% sz = size(yhat2);
% if strcmp(extra.atmos.N_values(test).WLP,'ACD')
%     h = get(gca,'children');
%     iterations = num2str(2:length(h)/3-2);
%     measurements = {'Measurements - A pair','Measurements - D pair','Measurements - D pair'};
%     legend(h,'initial',iterations,'final',measurements);
% end
% if sz(2) == 2
%     legend('initial','final','measurement','location','NorthWest');
% elseif sz(2) == 3
%     legend('initial','2','final','measurement','location','NorthWest');
% elseif sz(2) == 4
%     legend('initial','2','3','final','measurement','location','NorthWest');
% elseif sz(2) == 5
%     legend('initial','2','3','4','final','measurement','location','NorthWest');
% elseif sz(2) == 6
%     legend('initial','2','3','4','5','final','measurement','location','NorthWest');
% elseif sz(2) == 7
%     legend('initial','2','3','4','5','6','final','measurement','location','NorthWest');
% elseif sz(2) == 8
%     legend('initial','2','3','4','5','6','7','final','measurement','location','NorthWest');
% elseif sz(2) == 9
%     legend('initial','2','3','4','5','6','7','8','final','measurement','location','NorthWest');
% elseif sz(2) == 10
%     legend('initial','2','3','4','5','6','7','8','9','final','measurement','location','NorthWest');
% end

% set(fig, 'PaperPositionMode','auto');
% print('-dpng','-r0', strcat('/Users/stonek/work/Dobson/plots/retrievals/Initial/','Macquarie_Nvalue_',num2str(test),'.png'));
% delete(1); delete(3);
end







