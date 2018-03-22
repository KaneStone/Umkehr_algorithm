tic;

inputs = userinputs;
    
foldersandnames = namingconventions(inputs);

Umkehr = readUmkehr(inputs);

%only plot measurements
if inputs.plot_measurements
    return
end

for measurement_number = 1:length(Umkehr)
        
    currentUmkehr = Umkehr(measurement_number);
    
    %backing up data
    foldersandnames.currenttime = sprintf('%.4f',calculatedate);
    backupdata(inputs,foldersandnames);   
    
    %setting up retrieval inputs
    [setup,inputs,currentUmkehr] = retrievalsetup(currentUmkehr,...
        inputs);
    
    %initialise the forward model
    [K,simulatedNvalues] = ForwardModel(setup.atmos.ozone,setup,inputs,1);
    sz = size(setup.atmos.Apparent);
    
    %Setting up measurement covariance matrix
    [Se,Se_for_errors] = createSe(setup.atmos.true_actual,inputs.Se_scale_factor);    
         
    y = currentUmkehr.data.Nvalue;
    
    %For performing L-curve diagnostic
    if inputs.L_curve_diag
        RMS = createRMS(simulatedNvalues,Se,K,inputs,y,setup);   
        return
    end
    
    %Setting up a priori covariance matrix
    Sa = createSa(setup,inputs);  
    
    %Running the optimal estimation retrieval
    [xhat, yhat, K, yhat1, K1, S, Sdayy] = OptimalEstimation...
    (y,simulatedNvalues,Se,setup.atmos.ozone,Sa,K,setup,inputs);        
        
    %Converting retrieval to Umkehr output and saving data
    [g,g1,saveResult,saveErrorResult] = Umkehr_layers(setup,...
        currentUmkehr.data.WaveLengthPair,inputs,xhat,S,setup.atmos.Umkehrdate,...
        foldersandnames);    
    
    %Calculating averaging kernels and saving data
    [AK] = AveragingKernel(S,Sa,Se,setup,currentUmkehr.data.WaveLengthPair,...
        inputs,foldersandnames,K,g,g1);
    
    %printing diagnostics
    if inputs.print_diagnostics        
        [figs] = plot_retrieval(simulatedNvalues,yhat,setup,inputs,...
            setup.atmos.Umkehrdate,currentUmkehr.data.Nvalue,xhat,Sa,S,yhat1,...
            Se_for_errors,saveResult,saveErrorResult,g1);    
        print_diagnostics(figs,AK,setup,currentUmkehr.data.WaveLengthPair,...
            inputs,foldersandnames);   
    end    
    
    close all hidden
    clearvars -except inputs Umkehr foldersandnames
    toc;
end
