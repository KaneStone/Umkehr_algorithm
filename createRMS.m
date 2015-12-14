function [RMS] = createRMS(y,yhat,j,RMS)

a = reshape(y',1,numel(y))-reshape(yhat',1,numel(yhat));
RMS(j) = sqrt(sum(a.^2)/length(a));


if j == 15;
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
    
    export_fig('/Users/stonek/work/Dobson/OUTPUT/plots/optimisation/19940128_rm_ACD.pdf','-pdf');
end

   
end