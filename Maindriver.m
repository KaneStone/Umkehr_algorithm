tic;
test = 1;
a = 1;

station = 'Melbourne';
year = '1994';
mf = 0;

for i = 1:1
    extra = extrasetup(test,station,year);
    Kflg=1;
    AeroKflg=0;
    
    if extra.logswitch
        extra.atmos.ozone=log10(extra.atmos.ozone);        
        extra.pert = log10(.5e11);
    else extra.pert = .5e11;
    end
    
    if AeroKflg
        Aero_Weighting_Functions(AeroKflg,extra);
    end
    
    [K,N] = ForwardModel(extra.atmos.ozone, Kflg, AeroKflg, extra);
    sz = size(extra.atmos.Apparent);
    
    %Ki = K(sz(3)+1:2*sz(3),:);
    %yhat = yhat(sz(3)+1:2*sz(3),:);
    %plotWfunc(K, extra.atmos.Apparent);
    %plotNvalues(extra.atmos.true_actual, N.zs);
    
    Se = createSe(extra.atmos.true_actual);
    Sa = createSa(extra.atmos.quarter,extra.logswitch);
    
    %mf = mf+2;
    
    y = extra.atmos.N_values(test).N;
 
    y (isnan(y)) = [];
    [xhat yhat K yhat1 K1 S d2] = OptimalEstimation(y,N.zs,Se,extra.atmos.ozone,Sa,K,extra,'Opt');
    
    [fig1 fig2] = plot_retrieval(N,yhat,extra,xhat,Se,Sa,S,test,yhat1,station,extra.atmos.date(test).date);
    %RMS(i) = createRMS(y,yhat);
    [AK] = AveragingKernel(S,Sa,Se,extra,K);
 
    %print_diagnostics(fig1,fig2,AK,station,extra.atmos.date(test).date);
     
    test = test+1;
    clearvars -except test a station year i
end
time = toc;
display(time);
