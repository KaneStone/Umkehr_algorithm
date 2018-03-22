function [figs] = plot_retrieval(N,yhat,setup,inputs,date,N_val,xhat,Sa,S,...
    yhat1,Se_for_errors,saveResult,saveErrorResult,g1)

%% plotting ozone profile
figs.fig1 = figure;
colourOrder = get(gca,'ColorOrder');
set(figs.fig1,'color','white','Position',[100 100 1000 700],'Visible','off');
herror_handle = herrorbar(xhat,setup.atmos.Z/1000,(diag(S.S)).^.5);
set(herror_handle,'color',colourOrder(1,:));
set(herror_handle(2),'LineWidth',2)
hold on

herror_handle2 = herrorbar(setup.atmos.ozone,setup.atmos.Z/1000,(diag(Sa)).^.5);
set(herror_handle2,'color',colourOrder(2,:));
set(herror_handle2(2),'LineWidth',2)

ylabel('Altitude (km)','fontsize',20);
xlabel('Number density','fontsize',20);
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','Ozone Profile'),'fontsize',24);
profile_lh = legend([herror_handle(2) herror_handle2(2)],'Retrieval','A priori');
set(profile_lh,'location','NorthEast','box','off','fontsize',24);

N_val_error = Se_for_errors;
N_val_error = reshape(N_val_error,fliplr(size(N_val))).^.5;
res = N_val - yhat;
perc_of_Se = ((N_val-yhat)./reshape(Se_for_errors,fliplr(size(N_val)))')*100;
perc_of_Std = ((N_val-yhat)./N_val_error')*100;

%% plotting N_values
figs.fig2 = figure;
set(figs.fig2,'color','white','Position',[100 100 1000 700],'Visible', 'off');
h2 = errorbar(setup.atmos.true_actual',N_val',N_val_error,'LineWidth',1.5,'LineStyle','--','color','black');
hold on
colourord = [0,0.4470,0.7410;
            0.8500,0.3250,0.0980;  
            0.9290,0.6940,0.1250];
for i = 1:size(yhat,1)
    h1(i) = plot(setup.atmos.true_actual(i,:)',yhat(i,:)','color',colourord(i,:),'LineWidth',2);
    hold on
    h3(i) = plot(setup.atmos.true_actual(i,:)',(N_val(i,:)-yhat(i,:))','color',colourord(i,:),'LineStyle','--');
end
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
xlim([55 95])
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','N-Values'),'fontsize',24);

if strcmp(inputs.WLP_to_retrieve,'ACD')
   lh = legend(horzcat(h2(1),h1,h3),'Measurements','Retrieval - A pair',...
       'Retrieval - C pair','Retrieval - D pair','Residual - A pair',...
       'Residual - C pair','Residual - D pair');
   set(lh,'location','NorthWest','box','off','fontsize',24);
elseif strcmp(inputs.WLP_to_retrieve,'C')
    lh = legend('Measurements','Retrieval - C pair','Residual - C pair');
    set(lh,'location','NorthWest','box','off','fontsize',24);
elseif strcmp(inputs.WLP_to_retrieve,'AC')
    lh = legend([h1,h2(1),h3],'Retrieval - A pair','Retrieval - C pair','Measurements',...
        'Residual - A pair','Residual - C pair');
    set(lh,'location','NorthWest','box','off','fontsize',24);
elseif strcmp(inputs.WLP_to_retrieve,'CD')
    lh = legend([h1,h2(1),h3],'Retrieval - C pair','Retrieval - D pair','Measurements',...
        'Residual - C pair','Residual - D pair');
    set(lh,'location','NorthWest','box','off','fontsize',24);
end

for i = 1:length(yhat1)
    yhat1(i).y = reshape(yhat1(i).y',fliplr(size(N)))';
end
yhat2 = vertcat(N,yhat1.y)';
sz_yhat1 = size(yhat1);

%% plot iterations
figs.fig3 = figure;
set(figs.fig3,'color','white','Position',[100 100 1000 700],'Visible', 'off');
colourOrder = repmat(colourOrder,2,1);
for i = 1:sz_yhat1(2)
    colour = colourOrder(i,:);
    if i == 1
        pl(i).p = plot(setup.atmos.true_actual',N','color',colour,'LineWidth',2.5);
    else pl(i).p = plot(setup.atmos.true_actual',yhat1(i).y','color',colour,'LineWidth',2.5);
    end    
    
    legendhandle(i) = pl(i).p(1); 
    if i == 1
        legendnames{i} = 'Initial';
    elseif i >1 && i < sz_yhat1(2)+1
        legendnames{i} = num2str(i);
    elseif i == sz_yhat1(2)+1
        legendnames{i} = 'Final';        
    end    
    hold on
end
    
err = errorbar(setup.atmos.true_actual',N_val',N_val_error,'LineWidth',1,'LineStyle','--','color','k');
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
,'{ }','N-values'),'fontsize',24);
sz = size(yhat2);

legendhandle = [legendhandle,err(1)];
legendnames{i+1} = 'Measurements';

lh = legend(legendhandle,legendnames,'location','NorthWest');
set(lh,'location','NorthWest','box','off','fontsize',24);

%% plot layered retrieval
DU_coeff = 1e5*1.38e-21*1e3*(273.1/10.13);
figs.fig4 = figure;
set(figs.fig4,'color','white','Position',[100 100 1000 700],'Visible', 'off');

colourOrder = get(gca,'ColorOrder');
herror_handle = herrorbar(saveResult(5:end-1),1:8,saveErrorResult(5:end-1));
set(herror_handle,'color',colourOrder(1,:));
set(herror_handle(2),'LineWidth',2)
hold on

herror_handle2 = herrorbar(setup.atmos.ozone*g1'*DU_coeff,1:8,((diag(Sa)).^.5)'*g1'*DU_coeff);
set(herror_handle2,'color',colourOrder(2,:));
set(herror_handle2(2),'LineWidth',2)

ylabel('Umkehr layer','fontsize',20);
xlabel('DU','fontsize',20);
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))...
    ,'{ }','Ozone Umkehr Layer Profile'),'fontsize',24);
profile_lh = legend([herror_handle(2) herror_handle2(2)],'Retrieval','A priori');
set(profile_lh,'location','NorthEast','box','off','fontsize',24);

end
