tic;
measurement_number = 15;
station = 'Melbourne';
year = '1970';
sf = 0;
L_curve_diag = 0;
number_of_measurements = 11;

for i = 1:1;%number_of_measurements;
    extra = extrasetup(measurement_number,station,year);
    Kflg = 1;
    AeroKflg = 0;
    
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
    
    [Se Se_for_errors] = createSe(extra.atmos.true_actual);
    Sa = createSa(extra.atmos.quarter,extra.logswitch,extra,i,sf,L_curve_diag);
    sf = sf+4;
    
    y = extra.atmos.N_values(measurement_number).N;
    
    %Optimal estimation
    %y (isnan(y)) = [];
    [xhat yhat K yhat1 K1 S] = OptimalEstimation(y,N.zs,Se,extra.atmos.ozone,Sa,K,extra,'Opt');
    
    %printing diagnostics
    [fig1 fig2] = plot_retrieval(N,yhat,extra,xhat,Se,Sa,S,measurement_number,...
        yhat1,station,extra.atmos.date(measurement_number).date,Se_for_errors);
    if L_curve_diag
        RMS(i) = createRMS(y,yhat);
    end
    [AK] = AveragingKernel(S,Sa,Se,extra,K);
    print_diagnostics(fig1,fig2,AK,station,extra,measurement_number);
    
    measurement_number = measurement_number+1;
    if i == 1;
        number_of_measurements = length(extra.atmos.N_values);
    end
    close all hidden
    pause(1);
    clearvars -except measurement_number station year i sf L_curve_diag number_of_measurements
end
time = toc;
display(time);
