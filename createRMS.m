function [RMS] = createRMS(simulatedNvalues,Se,K,inputs,y,setup)

RMS = zeros(1,10);
a = zeros(15,numel(y));

inputs.Sa_scalefactor = 1;
for i = 1:length(RMS);    
    Sa = createSa(setup, inputs);  
    [~,yhat,~,~,~,~] = OptimalEstimation...
        (y,simulatedNvalues,Se,setup.atmos.ozone,Sa,K,setup,inputs);        
    a(i,:) = reshape(y',1,numel(y))-reshape(yhat',1,numel(yhat));
    RMS(i) = sqrt(sum(a(i,:).^2)/length(a(i,:)));
    inputs.Sa_scalefactor = inputs.Sa_scalefactor+1;
end

fontsize = 24;
figure;
h = gcf; 
set(h,'color','white','position',[100 100 900 700]);
plot(RMS(2:end),'Marker','+','MarkerEdgeColor','r','MarkerSize',12,'linewidth',2);
set(gca,'xtick',0:1:20,'xticklabel',0:1:20,'fontsize',fontsize-2);
set(gca,'ytick',0:1:9,'yticklabel',0:1:9,'fontsize',fontsize-2);
xlabel('Scale factor','fontsize',fontsize);
ylabel('RMS ({\bfy}-{\bfF}({\bfx}))','fontsize',fontsize);
axis([0 15 0 8]);
title('RMS of C-pair retrievals (Se = Se*10)',...
    'fontsize',fontsize+2);
%export_fig('/Users/stonek/work/Dobson/OUTPUT/plots/optimisation/19940128_rm_ACD.pdf','-pdf');
end