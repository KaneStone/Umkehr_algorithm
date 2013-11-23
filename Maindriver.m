tic;
test =1;
a = 1;

station = 'Perth';
year = '1982';

for i = 1:1
    extra = extrasetup(test,station,year);
    Kflg=1;
    
    if extra.logswitch
        extra.atmos.ozone=log10(extra.atmos.ozone);        
        extra.pert = log10(.5e11);
    else extra.pert = .5e11;
    end
    
    [K,N] = ForwardModel(extra.atmos.ozone, Kflg, extra);
    sz = size(extra.atmos.Apparent);

    %Ki = K(sz(3)+1:2*sz(3),:);
    %yhat = yhat(sz(3)+1:2*sz(3),:);
    %plotWfunc(K, extra.atmos.Apparent);
    %plotNvalues(extra.atmos.true_actual, N.zs);

    Se = createSe(extra.atmos.true_actual);
    Sa = createSa(extra.atmos.quarter,i);
%     a = a*.2e1;
%     if i ~= 1
%         Sa = Sa*a;
%     end
    
    y = extra.atmos.N_values(test).N;
 
    y (isnan(y)) = [];
    [xhat yhat K yhat1 K1 S] = OptimalEstimation(y,N.zs,Se,extra.atmos.ozone,Sa,K,extra,'Opt');
    
    [fig1 fig2] = plot_retrieval(N,yhat,extra,xhat,Se,Sa,test,yhat1,station,extra.atmos.date(test).date);
    %RMS(i) = createRMS(y,yhat);
    [AK] = AveragingKernel(S,Sa,Se,extra,K);
 
    print_diagnostics(fig1,fig2,AK,station,extra.atmos.date(test).date);
     
    %test = test+1;
    %clearvars -except test RMS a rms1 station year
end
time = toc;
display(time);

% figure;
% h = gcf; 
% set(h,'color','white','position',[100 100 900 700]);
% plot(RMS,'linewidth',2);
% set(gca,'xticklabel',{'Sa/2^5' 'Sa/2^4' 'Sa/2^3' 'Sa/2^2' 'Sa/2^1)' 'Sa' 'Sa*2^1' 'Sa*2^2' 'Sa*2^3' 'Sa*2^4'},'fontsize',16);;
% xlabel('Sa','fontsize',18);
% ylabel('RMS','fontsize',18);
% title('RMS of retrievals for different error covariance matrices (Se = Se*20)');

