function [fig1, fig2, fig3] = plot_retrieval(N,yhat,setup,inputs,date,N_val,xhat,Sa,S,...
    yhat1,Se_for_errors)


addpath('../data_code');

%plotting ozone profile
figure;
set(gcf, 'Visible', 'off')
fig1 = gcf;
colourOrder = get(gca,'ColorOrder');
set(fig1,'color','white','Position',[100 100 1000 700]);
herror_handle = herrorbar(xhat,setup.atmos.Z/1000,(diag(S.S)).^.5);
set(herror_handle,'color',colourOrder(1,:));
set(herror_handle(2),'LineWidth',2)
hold on

herror_handle2 = herrorbar(setup.atmos.ozone,setup.atmos.Z/1000,(diag(Sa)).^.5);
set(herror_handle2,'color',colourOrder(2,:));
set(herror_handle2(2),'LineWidth',2)

set(fig1,'color','white');
ylabel('Altitude','fontsize',20);
xlabel('number density','fontsize',20);
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','Ozone Profile'),'fontsize',24);
profile_lh = legend([herror_handle(2) herror_handle2(2)],'Retrieval','A priori');
set(profile_lh,'location','NorthEast','box','off','fontsize',24);

N_val_error = Se_for_errors;
N_val_error = reshape(N_val_error,fliplr(size(N_val))).^.5;
res = N_val - yhat;
perc_of_Se = ((N_val-yhat)./reshape(Se_for_errors,fliplr(size(N_val)))')*100;
perc_of_Std = ((N_val-yhat)./N_val_error')*100;

%close all;
%plotting N_values
figure;
set(gcf, 'Visible', 'off')
fig2 = gcf;
set(fig2,'color','white','Position',[100 100 1000 700]);
h2 = errorbar(setup.atmos.true_actual',N_val',N_val_error,'LineWidth',1.5,'LineStyle','--','color','black');
hold on
%set(gca, 'ColorOrder', [0 .5 0; 0 0 1; 1 0 0]);
h1 = plot(setup.atmos.true_actual',yhat','LineWidth',2);
%set(gca,'ColorOrderIndex',1);
h3 = plot(setup.atmos.true_actual',(N_val-yhat)','--');
ylabel('N-Value','fontsize',20);
xlabel('SZA','fontsize',20);
xlim([55 95])
set(gca,'fontsize',18);
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
    ,'{ }','N-Values'),'fontsize',24);
%char(Umkehr(measurement_number).data.WLP)'
if strcmp(inputs.WLP_to_retrieve,'ACD')
   lh = legend(vertcat(h2(1),h1,h3),'Measurements','Retrieval - A pair',...
       'Retrieval - C pair','Retrieval - D pair','Residual - A pair',...
       'Residual - C pair','Residual - D pair');
   set(lh,'location','NorthWest','box','off','fontsize',24);
elseif strcmp(inputs.WLP_to_retrieve,'C')
    lh = legend('Measurements','Retrieval - C pair','Residual - C pair');
    set(lh,'location','NorthWest','box','off','fontsize',24);
elseif strcmp(inputs.WLP_to_retrieve,'AC')
    lh = legend(vertcat(h1,h2(1),h3),'Retrieval - A pair','Retrieval - C pair','Measurements',...
        'Residual - A pair','Residual - C pair');
    set(lh,'location','NorthWest','box','off','fontsize',24);
end

for i = 1:length(yhat1)
    yhat1(i).y = reshape(yhat1(i).y',fliplr(size(N)))';
end
yhat2 = vertcat(N,yhat1.y)';
sz_yhat1 = size(yhat1);

%plot iterations
figure;
set(gcf, 'Visible', 'off')
fig3 = gcf;
set(fig3,'color','white','Position',[100 100 1000 700]);
colourOrder = repmat(colourOrder,2,1);
%color = 'b';
for i = 1:sz_yhat1(2)
    colour = colourOrder(i,:);
    if i == 1
        pl(i).p = plot(setup.atmos.true_actual',N','color',colour,'LineWidth',2.5);
    else pl(i).p = plot(setup.atmos.true_actual',yhat1(i).y','color',colour,'LineWidth',2.5);
    end    
    
    legendhandle(i) = pl(i).p(1); 
    if i == 1;
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
title(strcat(inputs.station,'{ }',num2str(date(1)),'/',num2str(date(2)),'/',num2str(date(3))...
,'{ }','N-values'),'fontsize',24);
sz = size(yhat2);

legendhandle = [legendhandle,err(1)];
legendnames{i+1} = 'Measurements';

lh = legend(legendhandle,legendnames,'location','NorthWest');
set(lh,'location','NorthWest','box','off','fontsize',24);

end







