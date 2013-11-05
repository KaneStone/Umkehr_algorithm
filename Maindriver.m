tic;
test =1;
a = 1;
for i = 1:1
    extra = extrasetup(test);
    extra.pert = .5e11;
    Kflg=1;
    
    if extra.logswitch
        extra.atmos.ozone=log10(extra.atmos.ozone);        
    end
    
    [K,N] = ForwardModel(extra.atmos.ozone, Kflg, extra);
    sz = size(extra.atmos.Apparent);

    %Ki = K(sz(3)+1:2*sz(3),:);
    %yhat = yhat(sz(3)+1:2*sz(3),:);
    %plotWfunc(K, extra.atmos.Apparent);
    %plotNvalues(extra.atmos.true_actual, N.zs);

    Se = createSe(extra.atmos.true_actual);
    Sa = createSa(extra.atmos.quarter,i);
    %a = a*.5e1;
    %if i ~= 1
    %    Sa = Sa*a;
    %end
    
    y = extra.atmos.N_values(test).N;
 
    y (isnan(y)) = [];
    [xhat yhat K yhat1 K1 S] = OptimalEstimation(y,N.zs,Se,extra.atmos.ozone,Sa,K,extra,'Opt');
    [RMS(i) rms1(i)] = createRMS(N.zs,yhat);
    [A] = AveragingKernel(S,Sa,Se,extra,K);
    plot_retrieval(N,yhat,extra,xhat,Se,Sa,test,yhat1);
    
    
    %test = test+1;
   % clearvars -except test RMS a rms1
end
time = toc;
display(time);


