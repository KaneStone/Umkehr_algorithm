function [A] = AveragingKernel(S,Sa,Se,extra,K)

A = S*(K'/Se*K);
%Area of the AK is a measure of the amount of information coming from the
%measurements relative to the a priori information, ideally = 1.0
area=sum(A,1);

%How many retrieval points required for each independent piece of
%information (degree of freedom)
resolution=1./diag(A);

%Degrees of Freedom for signal
Dof=sum(diag(A));

%Information content - 3D reduction in the error covariance volumes - how
%much information from measurements versus a priori
H;

%
%Ss - smoothing error component from the a priori error smoothing error
%Sn - noise  error component of the measurements in your retrievals
%Shat - both

%Sfm - propagate the fmp errors through retrieval - i.e. aerosol

end