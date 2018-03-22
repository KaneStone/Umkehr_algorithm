function [xhat, yhat, K, yhat1, K1, S, Sdayy] = OptimalEstimation(y,yhat,Se,xa,Sa,K,...
    setup,inputs)

%METHOD
%Optimal non-linear Gauss newton method

%OptimalEstimation function that solves the inversion of measurements given
%their errors, an a priori and associated error using a forward model 
%function that models the observations given the state vector. The formula 
%as given by Rodgers 1990 Pg 85 Eqn 5.8 or alternatively equations 5.9 and 
%5.10 can be used

%Outputs 
%xhat - the retrieved state vector
%yhat - here the modeled SCDs or DSCDs
%K - the weighting functions
%S - retrieval error covariance
%Sdayy - some other covariance

%Inputs
%y - measurement vector - N values
%Se - measurement error covariance matrix
%xa - a priori vector - climatology
%Sa - a priori covariance matrix

%for different wavelength pair vector length functionality
yhat = reshape(yhat',1,numel(yhat));
yhat1(1).y = yhat;
yhat (isnan(yhat)) = [];
y = reshape(y',1,numel(y));
y (isnan(y)) = [];

yhat2(1).y = yhat;
xa = xa';
xi = xa;
di2 = length(y);

i = 1;
while di2 >= length(y) && i < 8 %Stops due to convergence test.
    K1(i).K = K;
    %reshaping into one vector for all wavelengths               
    yhat = reshape(yhat',1,numel(yhat));
    yhat (isnan(yhat)) = [];
    
    %Rodger's equation 5.9 - N-form  
    %xhat = xa + ((inv(Sa)+(K'/Se*K))\(K'/Se)*((y'-yhat')+K*(xi-xa)));  
    
    %Rodger's equation 5.10 - M-form  
    xhat = xa + Sa*K'*((K*Sa*K'+Se)\(y'-yhat'+K*(xi-xa)));                

    %continue on with next iteration by calling forward model
    xi = xhat;
    xhat = xhat';
    [K,simulatedNvalues]=ForwardModel(xhat,setup,inputs,0);
    yhat = simulatedNvalues;  
    
    %output for plotting
    yhat1(i+1).y = reshape(yhat',1,numel(yhat));    

    %testing for convergence
    yhat2(i+1).y = reshape(yhat',1,numel(yhat));
    yhat2(i+1).y (isnan(yhat2(i+1).y)) = [];
    Sdayy = Se*(K*Sa*K'+Se)\Se;
    di2 = (yhat2(i+1).y-yhat2(i).y)*(Sdayy\(yhat2(i+1).y-yhat2(i).y)');                                
    
    i = i+1;
end
S.Ss = ((K'*(Se^-1)*K +Sa^-1)^-1*(Sa\((K'*(Se^-1)*K +Sa^-1)^-1)));
S.Sm = ((K'*(Se^-1)*K +Sa^-1)^-1)*(K'*(Se\K))*((K'*(Se^-1)*K +Sa^-1)^-1);
S.Ss_plus_Sm = S.Ss+S.Sm;
S.S = (K'*(Se^-1)*K +Sa^-1)^-1;

end





