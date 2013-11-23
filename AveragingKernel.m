function [AK] = AveragingKernel(S,Sa,Se,extra,K)

AK.AK = S*(K'/Se*K);
%Area of the AK is a measure of the amount of information coming from the
%measurements relative to the a priori information, ideally = 1.0
AK.area=sum(AK.AK,1);

%How many retrieval points required for each independent piece of
%information (degree of freedom)
AK.resolution=1./diag(AK.AK);

%Degrees of Freedom for signal
AK.dof=sum(diag(AK.AK));

%Information content - 3D reduction in the error covariance volumes - how
%much information from measurements versus a priori
%H;

%
%Ss - smoothing error component from the a priori error smoothing error
%Sn - noise  error component of the measurements in your retrievals
%Shat - both

%Sfm - propagate the fmp errors through retrieval - i.e. aerosol

end