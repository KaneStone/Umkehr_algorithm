tic;

%inputs for files to retrieve
measurement_number = 46;
station = 'Melbourne';
year = '1971';

%for covariance matrix diagnostics
scale_factor = 0;
L_curve_diag = 0;

%Switches for retrieving either Aerosol or Ozone profiles
L_Aerosol = 0;
L_Ozone = 1;

for i = 1:1;
    extra = extrasetup(measurement_number,station,year);
    if L_Ozone == 1
        Kflg = 1;
        AeroKflg = 0;
    elseif L_Aerosol == 1 
        AeroKflg = 1;
        Kflg = 0;
    end
    
    if extra.logswitch
       extra.atmos.ozone=log10(extra.atmos.ozone);        
    end
    
    if AeroKflg
        Aero_Weighting_Functions(AeroKflg,extra);
    end
    
    [K,N] = ForwardModel(extra.atmos.ozone, Kflg, AeroKflg, extra);
    sz = size(extra.atmos.Apparent);
    
    [Se Se_for_errors] = createSe(extra.atmos.true_actual);
    
    if L_Ozone
        Sa = createSa(extra.atmos.quarter,extra.atmos.date_to_use,...
            extra.seasonal,extra.logswitch,extra,i,scale_factor,...
            L_curve_diag,station);
        %scale_factor = scale_factor+4;
        y = extra.atmos.N_values(measurement_number).N;
        [xhat yhat K yhat1 K1 S Sdayy] = OptimalEstimation...
            (y,N.zs,Se,extra.atmos.ozone,Sa,K,extra,'Opt');
    elseif L_Aerosol
        Sa = createSaAer;
        %scale_factor = scale_factor+4;
        y = extra.atmos.N_values(measurement_number).N;
        [xhat yhat K yhat1 K1 S] = AerOptimalEstimation...
            (y,N.zs,Se,extra.atmos.Aer,Sa,K,extra);
    end
    
    %printing diagnostics
    [fig1 fig2 fig3] = plot_retrieval(N,yhat,extra,xhat,Sa,S,...
        measurement_number,yhat1,station,...
        extra.atmos.date(measurement_number).date,Se_for_errors,L_Ozone);
    if L_curve_diag
        RMS(i) = createRMS(y,yhat);
    end
    
    g = Umkehr_layers(extra,xhat,station,measurement_number,L_Ozone,S);    
    [AK] = AveragingKernel(S,Sa,Se,extra,K,g,station,measurement_number);
    print_diagnostics(fig1,fig2,fig3,AK,station,extra,...
        measurement_number,L_Ozone);
    measurement_number = measurement_number+1;
    %X2 = (y-yhat)*(Sdayy\(y-yhat)');
    close all hidden
    clearvars -except measurement_number station year i sf L_curve_diag...
        number_of_measurements L_Ozone L_Aerosol scale_factor
end
time = toc;
display(time);
