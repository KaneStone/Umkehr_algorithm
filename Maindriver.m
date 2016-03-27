tic;

inputs = userinputs;

Umkehr = readUmkehr(inputs);

for measurement_number = 1:length(Umkehr)
    
    %[log] = logfile();
    currentUmkehr = Umkehr(measurement_number);
    
    [setup, userinputs, currentUmkehr, foldersandnames] = retrievalsetup(currentUmkehr,...
        inputs);
    
%     if userinputs.plot_measurements
%         plot_measurements(extra.atmos,extra.theta,station,1);
%         return
%     end
    
    [K,N] = ForwardModel(setup.atmos.ozone, setup, inputs);
    sz = size(setup.atmos.Apparent);
    
    %Setup Measurement covariance matrix
    [Se, Se_for_errors] = createSe(setup.atmos.true_actual,inputs.Se_scale_factor);
    
    RMS = [];
    j = 1;
            
    Sa = createSa(setup, inputs);
    %scale_factor = scale_factor+4;
    y = currentUmkehr.data.Nvalue;
    [xhat, yhat, K, yhat1, K1, S, Sdayy] = OptimalEstimation...
    (y,N,Se,setup.atmos.ozone,Sa,K,setup,inputs,'Opt');
    
    if inputs.L_curve_diag
        RMS = createRMS(y,yhat,j,RMS);        
    end
    
    %printing diagnostics
    [fig1, fig2, fig3] = plot_retrieval(N,yhat,setup,inputs,setup.atmos.Umkehrdate,...
        currentUmkehr.data.Nvalue,xhat,Sa,S,yhat1,Se_for_errors);
    
    [g, g1] = Umkehr_layers(setup,Umkehr.data.WLP,inputs,xhat,S,setup.atmos.Umkehrdate,...
        foldersandnames);    
    [AK] = AveragingKernel(S,Sa,Se,setup,Umkehr.data.WLP,inputs,foldersandnames,K,g,g1);
    if inputs.print_diagnostics
        print_diagnostics(fig1,fig2,fig3,AK,setup,Umkehr.data.WLP,inputs,foldersandnames);   
    end    
    close all hidden
    clearvars -except inputs Umkehr
end
fclose('all'); 
time = toc;
display(time);
