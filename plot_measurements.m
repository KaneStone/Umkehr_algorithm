function [] = plot_measurements(Umkehr,inputs)

%plotting
lwidth = 3;
fsize = 24;


for i = 1:length(Umkehr)
    date = datevec(Umkehr(i).data.Time(1));
    figure;
    fig = gcf;
    set(fig,'color','white','position',[100 100 900 700],'Visible','off');

    ph = plot(Umkehr(i).data.SolarZenithAngle',Umkehr(i).data.Nvalue','-+','LineWidth',lwidth);
        
    ylim([min(Umkehr(i).data.Nvalue(:))-2 max(Umkehr(i).data.Nvalue(:))+2]);
    xlim([min(Umkehr(i).data.SolarZenithAngle(:))-2 max(Umkehr(i).data.SolarZenithAngle(:))+2]);
    title([inputs.station,'{ }',num2str(date(1)),'/',sprintf('%02d',date(2)),'/',sprintf('%02d',date(3))],'fontsize',fsize+4);    
    set(gca,'fontsize',fsize)
    ylabel('N-value','fontsize',fsize+2)
    xlabel('Solar zenith angle (degrees)','fontsize',fsize+2)
    
    WLPs = char(Umkehr(i).data.WLP);    
    for j = 1:length(WLPs);
        legendnames{j} = [WLPs(j),'-pair'];
    end
    lh = legend(ph,legendnames);
    set(lh,'location','NorthWest','fontsize',fsize,'box','off');
    
    filename = ['../output/diagnostics/measurements/',inputs.station,'_',num2str(date(1)),...
        sprintf('%02d',date(2)),sprintf('%02d',date(3)),'.pdf'];
    export_fig(filename,'-pdf');
    
    close all
end

end