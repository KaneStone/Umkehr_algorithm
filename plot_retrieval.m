function [] = plot_retrieval(N,yhat,extra,xhat,Se,Sa,test,yhat1)

figure;
fig = gcf;
set(fig,'color','white','Position',[100 100 1000 700]);
plot(xhat,1:61,'r','LineWidth',2)
hold on
addpath('/Users/stonek/work/Dobson/data_code');
herrorbar(extra.atmos.ozone,1:61,(diag(Sa)).^.5);
plot(extra.atmos.ozone,1:61,'LineWidth',2);
set(fig,'color','white');
ylabel('Altitude','fontsize',20);
xlabel('number density','fontsize',20);
title('Macquarie Ozone Profile','fontsize',24);
legend('retrieval','A prioir','location','NorthWest');

set(fig, 'PaperPositionMode','auto');
print('-dpng','-r0', strcat('/Users/stonek/work/Dobson/plots/retrievals/Initial/','Macquarie_profile_',num2str(test),'.png'));

N_val = extra.atmos.N_values(test).N;
%N_val = load('Ret_as_Meas');
N_val (isnan(N_val)) = [];

error = (diag(Se)).^.5;
%error = vertcat(error(1:31)',error(32:62)',error(63:end)');

figure;
fig = gcf;
set(fig,'color','white','Position',[100 100 1000 700]);
plot(extra.atmos.true_actual',yhat','r','LineWidth',2);
hold on
%plot(extra.atmos.true_actual',N_val','LineWidth',2);
errorbar(extra.atmos.true_actual',N_val',error','LineWidth',2);
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
title('Macquarie N-values','fontsize',24);
legend('retrieval','measurement','location','NorthWest');

yhat2 = vertcat(yhat1.a)';
figure;
fig = gcf;
set(fig,'color','white','Position',[100 100 1000 700]);
plot(extra.atmos.true_actual,yhat2','LineWidth',2);
hold on
errorbar(extra.atmos.true_actual,N_val,(diag(Se)).^.5,'LineWidth',2,'color','black','LineStyle','--');
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
title('Macquarie N-values','fontsize',24);
sz = size(yhat2);
plot(extra.atmos.true_actual,N_val-yhat);
if sz(2) == 2
    legend('initial','final','measurement','location','NorthWest');
elseif sz(2) == 3
    legend('initial','2','final','measurement','location','NorthWest');
elseif sz(2) == 4
    legend('initial','2','3','final','measurement','location','NorthWest');
elseif sz(2) == 5
    legend('initial','2','3','4','final','measurement','location','NorthWest');
elseif sz(2) == 6
    legend('initial','2','3','4','5','final','measurement','location','NorthWest');
elseif sz(2) == 7
    legend('initial','2','3','4','5','6','final','measurement','location','NorthWest');
elseif sz(2) == 8
    legend('initial','2','3','4','5','6','7','final','measurement','location','NorthWest');
elseif sz(2) == 9
    legend('initial','2','3','4','5','6','7','8','final','measurement','location','NorthWest');
elseif sz(2) == 10
    legend('initial','2','3','4','5','6','7','8','9','final','measurement','location','NorthWest');
end

% set(fig, 'PaperPositionMode','auto');
% print('-dpng','-r0', strcat('/Users/stonek/work/Dobson/plots/retrievals/Initial/','Macquarie_Nvalue_',num2str(test),'.png'));
% delete(1); delete(3);
end







