function inputs = userinputs

%Define user inputs
inputs.station = 'Melbourne';       % Dobson station
inputs.daterange = [19940119];      % Specific date/s to retrieve as number (e.g. yyyymmdd (19940119) or range of dates within months (e.g. [199301,199405])
inputs.logswitch = 0;               % Retrieve in log space (currently doesn't work)
inputs.mieswitch = 1;               % Include Mie scattering
inputs.refraction = 1;              % Include refraction
inputs.normalise = 'cloudflag';     %'lowest', 'cloudflag' or 'no' Normalise measurments at lowest SZA
inputs.WLP_to_retrieve = 'ACD';     % Define wavelength pairs to retrieve (alphabetical order)
inputs.morn_or_even = 'both';       % only invoked if both morning and evening measurements are taken on same day
inputs.seasonal = 'monthly';        % 'monthly', 'seasonal' or 'constant' for ozone, temperature, and pressure profiles
inputs.designated_SZA = 1;          % retrieve using designated SZAs (not infallable)
inputs.plot_intensities = 0;        % plot intensity curves for selected SZAs (diagnostic code)
inputs.test_model_height_limit = 0; % switch for testing model height limit on zenith paths
inputs.full_covariance = 1;         % produce Sa matrix using Rodgers definition
inputs.covariance_type = 'diagonal';% 'full_covariance' or 'diagonal'
inputs.L_curve_diag = 0;            % produce L_curve for Sa optimisation (does not produce regular retrieval)
inputs.Lcurve_mult_fact = 0;        % not a switch but starting L_curve scale factor
inputs.SZA_limit = 94;              % upper limit of SZA to use
inputs.test_cloud_effect = 0;
inputs.plot_measurements = 0;       % diagnostic to just plot measurements.
inputs.plot_pathlength = 0;         % plot path length for lowest SZA
inputs.print_diagnostics = 1;       % specifying whether or not to print figure diagnostics
inputs.createlogfile = 1;           % outputs descriptive log file
inputs.cross_section= 'SG';         % 'BP' (Bass-Paur), 'BDM' (Brion-Daumont-Malicet), or 'SG' (Serdyuchenko-Gorshelev).
inputs.maximum_altitude = 80000;    % metres
inputs.dz = 1000;                   % Model layer width (metres)
inputs.Sa_scalefactor = 6;
inputs.Se_scale_factor = 10;

end