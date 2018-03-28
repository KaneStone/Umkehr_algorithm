function inputs = userinputs

%Define user inputs

%measurement inputs
inputs.station = 'Melbourne';       % Dobson station
inputs.daterange = [199401 199404];      % Specific date/s to retrieve as number (e.g. yyyymmdd (19940119)) or range of dates within months (e.g. [199301,199405])
inputs.WLP_to_retrieve = 'C';       % Define wavelength pairs to retrieve (alphabetical order)
inputs.SZA_limit = 94;              % upper SZA limit
inputs.morn_or_even = 'Both';       % 'both', 'Evening' or 'Morning'. -  
inputs.normalise = 'cloudflag';     %'lowest', 'cloudflag' or 'no'. - Normalise measurments at certain SZA
inputs.designated_SZA = 0;          % switch (1 or 0) - Retrieve using designated SZAs (not infallable)
inputs.plot_measurements = 0;       % switch (1 or 0) - Diagnostic to only plot measurements (will not produce a retrieval).
inputs.bandpass = 1;

%radiative transfer inputs
inputs.mieswitch = 1;               % switch (1 or 0) - Include Mie scattering
inputs.refraction = 1;              % switch (1 or 0) - Include refraction

%retrieval inputs
inputs.covariance_type = 'full_covariance';        % 'full_covariance_constant', 'full_covariance', 'full_covarianceSD', 'diagonal' or 'diagonalSD'
inputs.L_curve_diag = 0;            % switch (1 or 0) - produce L_curve for Sa optimisation (does not produce regular retrieval)
inputs.print_diagnostics = 1;       % switch (1 or 0) - specifying whether or not to print figure diagnostics
inputs.createlogfile = 1;           % switch (1 or 0) - outputs descriptive log file
inputs.Sa_scalefactor = 4;          % scale factor for a priori covariance matrix
inputs.Se_scale_factor = 10;        % scale factor for measurement covariance matrix

%Forward model inputs
inputs.seasonal = 'monthly';        % 'monthly', 'seasonal' or 'constant' for ozone, temperature, and pressure profiles
inputs.plot_pathlength = 0;         % plot path length for lowest SZA
inputs.cross_section= 'SG';         % 'BP' (Bass-Paur), 'BDM' (Brion-Daumont-Malicet), or 'SG' (Serdyuchenko-Gorshelev).
inputs.maximum_altitude = 80000;    % metres
inputs.dz = 1000;                   % Model layer width (metres - must be a factor of 10000)

%model performance and measurement effects inputs
inputs.plot_intensities = 0;        % plot intensity curves for selected SZAs (diagnostic code)
inputs.test_model_height_limit = 0; % switch for testing model height limit on zenith paths (diagnostic code)
inputs.test_cloud_effect = 0;       % perturb intensities at low SZAs (diagnostic code)

%backup
inputs.numofbackups = 5; % number of backups for retrieval output.

end