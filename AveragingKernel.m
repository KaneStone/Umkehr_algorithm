function [AK] = AveragingKernel(S,Sa,Se,extra,K,g,g1,station,measurement_number)

AK.AK = S*(K'/Se*K);
%Area of the AK is a measure of the amount of information coming from the
%measurements relative to the a priori information, ideally = 1.0
AK.area=sum(AK.AK,1);

AK.AK1 = g*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';
AK.AK2 = g1*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
AK.AK2(:,1:2) = AK.AK2(:,1:2)/10;
AK.AK2(:,3:7) = AK.AK2(:,3:7)/5;
AK.AK2(:,8) = AK.AK2(:,8)/35;


S1 = g*S(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';
%S3 = g1*S(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
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
    station,'/',WLP,'/AK/',sprintf('%d',date(3)),'/',station,'_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),'.txt'),'AK_to_print','-ascii');

%Ss - smoothing error component from the a priori error smoothing error
%Sn - noise  error component of the measurements in your retrievals
%Shat - both

%Sfm - propagate the fmp errors through retrieval - i.e. aerosol

end