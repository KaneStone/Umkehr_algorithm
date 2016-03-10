tic;

%inputs for files to retrieve

inputs = userinputs;

addpath('/Users/kanestone/work/supportCode/splineFit/')
addpath('/Users/kanestone/work/supportCode/exportFig/')
addpath('/Users/kanestone/work/supportCode/herrorbar/')

Umkehr = readUmkehr(inputs);

for measurement_number = 1:length(Umkehr.data)
    
    %[log] = logfile();
    
    [setup, userinputs, Umkehr, foldersandnames] = retrievalsetup(Umkehr(measurement_number),...
        measurement_number,inputs);
    
    if userinputs.plot_measurements
        plot_measurements(extra.atmos,extra.theta,station,measurement_number,1);
        return
    end
    
    [K,N] = ForwardModel(setup.atmos.ozone, setup, inputs);
    sz = size(setup.atmos.Apparent);
    
    %Setup Measurement covariance matrix
    [Se, Se_for_errors] = createSe(setup.atmos.true_actual);
    
    RMS = [];
    j = 1;
            
    Sa = createSa(setup, inputs);
    %scale_factor = scale_factor+4;
    y = Umkehr(measurement_number).data.Nvalue;
    [xhat, yhat, K, yhat1, K1, S, Sdayy] = OptimalEstimation...
    (y,N,Se,setup.atmos.ozone,Sa,K,setup,inputs,'Opt');
    
    if inputs.L_curve_diag
        RMS = createRMS(y,yhat,j,RMS);        
    end
    
    %printing diagnostics
    [fig1, fig2, fig3] = plot_retrieval(N,yhat,setup,inputs,Umkehr,xhat,Sa,S,measurement_number, ...
        yhat1,Se_for_errors);
    
    [g, g1] = Umkehr_layers(setup,inputs,xhat,measurement_number,S,...
        Umkehr(measurement_number).data.Time, foldersandnames);    
    [AK] = AveragingKernel(S,Sa,Se,setup,inputs,foldersandnames,K,g,g1,measurement_number, ...
        Umkehr(measurement_number).data.Time);
    if inputs.print_diagnostics
        print_diagnostics(fig1,fig2,fig3,AK,setup,inputs,foldersandnames);   
    end    
    close all hidden
    clearvars -except measurement_number station year i sf...
        number_of_measurements L_Ozone L_Aerosol atmos_init measurement_length Umkehr_path
end
fclose('all'); 
time = toc;
display(time);
