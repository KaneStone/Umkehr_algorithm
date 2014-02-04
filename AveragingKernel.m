function [AK] = AveragingKernel(S,Sa,Se,extra,K,g,station,measurement_number)

AK.AK = S*(K'/Se*K);
%Area of the AK is a measure of the amount of information coming from the
%measurements relative to the a priori information, ideally = 1.0
AK.area=sum(AK.AK,1);

AK.AK1 = g*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';


S1 = g*S(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';
S2 = (diag(S1^.5)).*(1e5*1.38e-21*1e3*(273.1/10.13));
%How many retrieval points required for each independent piece of
%information (degree of freedom)
AK.resolution=1./diag(AK.AK);

%Degrees of Freedom for signal
AK.dof=sum(diag(AK.AK));

AK.dof1=g*trace(AK.AK);
%Information content - 3D reduction in the error covariance volumes - how
%much information from measurements versus a priori
%H;

AK_to_print = AK.AK1;
date = extra.atmos.date(measurement_number).date;
WLP = extra.atmos.N_values(measurement_number).WLP;

save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/',...  
    station,'/',WLP,'/AK/',station,'_',WLP,'_AK_',num2str(date(3)),'-',num2str(date(2))...
    ,'-',num2str(date(1)),'.txt'),'AK_to_print','-ascii');

%
%Ss - smoothing error component from the a priori error smoothing error
%Sn - noise  error component of the measurements in your retrievals
%Shat - both

%Sfm - propagate the fmp errors through retrieval - i.e. aerosol

end