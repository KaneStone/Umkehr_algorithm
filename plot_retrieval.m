function [fig1 fig2] = plot_retrieval(N,yhat,extra,xhat,Se,Sa,S,measurement_number,yhat1,station,date,Se_for_errors)


addpath('/Users/stonek/work/Dobson/data_code');
figure;
fig1 = gcf;
set(fig1,'color','white','Position',[100 100 1000 700]);
herrorbar(xhat,1:extra.atmos.nlayers,(diag(S)).^.5,'r');
hold on
p1 = plot(xhat,1:extra.atmos.nlayers,'r','LineWidth',2);
herrorbar(extra.atmos.ozone,1:extra.atmos.nlayers,(diag(Sa)).^.5);
p2 = plot(extra.atmos.ozone,1:extra.atmos.nlayers,'LineWidth',2);
set(fig1,'color','white');
ylabel('Altitude','fontsize',20);
xlabel('number density','fontsize',20);
set(gca,'fontsize',18);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Ozone Profile'),'fontsize',24);
legend([p1 p2],'retrieval','A priori','location','NorthWest');

%set(fig1, 'PaperPositionMode','auto');
%print('-dpsc2','-r200', strcat('/Users/stonek/work/Dobson/plots/retrievals/Initial/','Hobart_profile_',num2str(measurement_number),'.eps'));

N_val = extra.atmos.N_values(measurement_number).N;

N_val_error = Se_for_errors;
N_val_error = reshape(N_val_error,fliplr(size(N_val))).^.5;

figure;
fig2 = gcf;
set(fig2,'color','white','Position',[100 100 1000 700]);
plot(extra.atmos.true_actual',yhat','LineWidth',2);
hold on
%plot(extra.atmos.true_actual',N_val','LineWidth',2);
errorbar(extra.atmos.true_actual',N_val',N_val_error,'LineWidth',1.5,'LineStyle','--','color','black');
plot(extra.atmos.true_actual',(N_val-yhat)');
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
set(gca,'fontsize',18);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','N Values'),'fontsize',24);
%legend('retrieval','measurement','location','NorthWest');
if strcmp(extra.atmos.N_values(measurement_number).WLP,'ACD')
    legend('Retrieval - A pair','Retrieval - C pair','Retrieval - D pair',...
        'Measurement - A pair','Measurement - C pair','Measurement - D pair',...
        'y-yhat','y-yhat','y-yhat','location','NorthWest');
elseif strcmp(extra.atmos.N_values(measurement_number).WLP,'C')
    legend('Retrieval - C pair','measurement','y-yhat','location','NorthWest');
end

%yhat1.a = reshape(yhat1.a',fliplr(size(N.zs)))';

yhat2 = vertcat(N.zs,yhat1.a)';
sz_yhat1 = size(yhat1);
figure;
fig = gcf;
set(fig,'color','white','Position',[100 100 1000 700]);
%plot(repmat(extra.atmos.true_actual,sz_yhat1(2)/3+1,1)'

color = 'b';
for i = 1:sz_yhat1(2)+1
    if i == 1
        pl(i).p = plot(extra.atmos.true_actual',N.zs',color,'LineWidth',2.5);
    else pl(i).p = plot(extra.atmos.true_actual',yhat1(i-1).a',color,'LineWidth',2.5);
    end
    if color == 'b'
        color = 'r';        
    elseif color == 'r'
        color = 'g';
    elseif color == 'g'
        color = 'k';
    elseif color == 'k'
        color = 'c';
    elseif color == 'c'
        color = 'm';
    elseif color == 'm'
        color = 'y';
    end
    
    legendhandle(i) = pl(i).p(1); 
    if i == 1;
        legendnames{i} = 'initial';
    elseif i >1 && i < sz_yhat1(2)+1
        legendnames{i} = num2str(i);
    elseif i == sz_yhat1(2)+1
        legendnames{i} = 'final';        
    end    
    hold on
end
    
err = errorbar(extra.atmos.true_actual',N_val',N_val_error,'LineWidth',1,'LineStyle','--','color','k');
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
set(gca,'fontsize',18);
title(strcat(station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
,'{ }','N-values'),'fontsize',24);
sz = size(yhat2);

legendhandle = [legendhandle,err(1)];
legendnames{i+1} = 'measurements';

legend(legendhandle,legendnames)

%set(fig, 'PaperPositionMode','auto');
%print('-dpsc2','-r200', strcat('/Users/stonek/work/Dobson/plots/retrievals/Initial/','Hobart_Nvalue_',num2str(measurement_number),'.eps'));
%delete(1); delete(3);
end







