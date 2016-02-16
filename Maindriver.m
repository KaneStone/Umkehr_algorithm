tic;

%inputs for files to retrieve
station = 'Melbourne';
year = '1970';
addpath('/Users/kanestone/work/supportCode/splineFit/')
addpath('/Users/kanestone/work/supportCode/exportFig/')
addpath('/Users/kanestone/work/supportCode/herrorbar/')
Umkehr_path = '../input/Umkehr/';
for noyears = 1
 
measurementfilename = strcat(Umkehr_path,station,'/',station,...
     '_',year,'.txt');
[atmos_init, measurement_length] = read_in_Umkehr(measurementfilename);

for measurement_number = 21%:measurement_length;
    
    extra = extrasetup(atmos_init,measurement_number,station,year);
    if extra.plot_measurements
        plot_measurements(extra.atmos,extra.theta,station,measurement_number,1);
        return
    end
        
    if extra.no_data
        clearvars -except measurement_number station year i sf...
        number_of_measurements L_Ozone L_Aerosol atmos_init measurement_length Umkehr_path
        continue
    end
    if extra.L_Ozone == 1
        Kflg = 1;
        AeroKflg = 0;
    elseif extra.L_Aerosol == 1 
        AeroKflg = 1;
        Kflg = 0;
    end       
    
    if AeroKflg
        Aero_Weighting_Functions(AeroKflg,extra);
    end
    
    [K,N] = ForwardModel(extra.atmos.ozone, Kflg, AeroKflg, extra);
    sz = size(extra.atmos.Apparent);
    
    %Setup Measurement covariance matrix
    [Se, Se_for_errors] = createSe(extra.atmos.true_actual);
    
    RMS = [];
    j = 1;
    scale_factor = 6;
    %for j = 1:15
    if extra.L_Ozone                
        Sa = createSa(extra.atmos.quarter,extra.atmos.date_to_use,...
            extra.seasonal,extra.logswitch,extra,measurement_number,...
            extra.L_curve_diag,station,extra.covariance_type,scale_factor);
        %scale_factor = scale_factor+4;
        y = extra.atmos.N_values(measurement_number).N;
        [xhat, yhat, K, yhat1, K1, S, Sdayy] = OptimalEstimation...
            (y,N.zs,Se,extra.atmos.ozone,Sa,K,extra,'Opt');
    elseif extra.L_Aerosol
        Sa = createSaAer;
        %scale_factor = scale_factor+4;
        y = extra.atmos.N_values(measurement_number).N;
        [xhat, yhat, K, yhat1, K1, S] = AerOptimalEstimation...
            (y,N.zs,Se,extra.atmos.Aer,Sa,K,extra,extra.full_covariance);
    end
    
    if extra.L_curve_diag
        RMS = createRMS(y,yhat,j,RMS);        
    end
    %scale_factor = scale_factor+1;
    %clearvars xhat yhat K yhat1 K1 S Sdayy
    %if j == 15        
    %    break
    %end
    %end
    %printing diagnostics
    [fig1, fig2, fig3] = plot_retrieval(N,yhat,extra,xhat,Sa,S,...
        measurement_number,yhat1,station,...
        extra.atmos.date(measurement_number).date,Se_for_errors,extra.L_Ozone);
    
    [g, g1] = Umkehr_layers(extra,xhat,station,measurement_number,extra.L_Ozone,S,extra.seasonal);    
    [AK] = AveragingKernel(S,Sa,Se,extra,K,g,g1,station,measurement_number,extra.seasonal);
    if extra.print_diagnostics
        print_diagnostics(fig1,fig2,fig3,AK,station,extra,...
            measurement_number,extra.L_Ozone,extra.seasonal);   
    end    
    close all hidden
    clearvars -except measurement_number station year i sf...
        number_of_measurements L_Ozone L_Aerosol atmos_init measurement_length Umkehr_path
end
year = num2str(str2double(year)+1);
fclose('all'); 
end
time = toc;
display(time);
