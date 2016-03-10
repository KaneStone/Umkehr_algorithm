function [xhat, yhat, K, yhat1, K1, S, Sdayy] = OptimalEstimation(y,yhat,Se,xa,Sa,K,...
    setup,inputs,method)

%METHOD
%MAP = Maximum A posterior
%Opt = Optimal non-linear Gauss newton method
%LS = Least Squares

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

sz = size(setup.atmos.Apparent);
yhat2(1).y = yhat;
xa = xa';
xi = xa;
di2 = length(y);
if strcmp(method,'Opt')
    %for i = 1:3; %Number of iterations
    i = 1;
    while di2 >= length(y) && i < 8 %Stops due to convergence test.
        K1(i).K = K;
        %reshaping into one vector for all wavelengths               
        yhat = reshape(yhat',1,numel(yhat));
        yhat (isnan(yhat)) = [];
        
        %5.8
        %xhat = xi + (inv(inv(Sa)+(K'/Se*K))\(K'/Se*(y'-yhat') - (Sa\(xi-xa))));
        
        %5.9 - N-form
        %xhat = xa + ((inv(Sa)+(K'/Se*K))\(K'/Se)*((y'-yhat')+K*(xi-xa)));        
        
        %5.10 - M-form  
        if inputs.logswitch
            xalog = log(xa);
            xilog = log(xi);
            Salog = log(Sa);
            %xhatlog = xalog+log(Sa)*K'*((K*log(Sa)*K'+Se)\(y'-yhat'+K*(xilog-xalog)));                        
            xhatlog = xalog+Salog*K'*((K*Salog*K'+Se)\(y'-yhat'+K*(xilog-xalog)));                        
            
            xhat = exp(xhatlog);
            %xhat2 = exp(xhatlog2);
        else       
            xhat = xa + Sa*K'*((K*Sa*K'+Se)\(y'-yhat'+K*(xi-xa)));            
        end
        
        %continue on with next iteration by calling forward model
        xi = xhat;
        xhat = xhat';
        [K,N]=ForwardModel(xhat,setup,inputs);
        yhat = N;
        %yhat (isnan(yhat)) = [];
        %yhat1(i).a = reshape(yhat',1,numel(yhat));
        yhat1(i+1).y = reshape(yhat',1,numel(yhat));
        yhat2(i+1).y = reshape(yhat',1,numel(yhat));
        yhat2(i+1).y (isnan(yhat2(i+1).y)) = [];
        
        %%%TESTING FOR CONVERGENCE%%%
        Sdayy = Se*(K*Sa*K'+Se)\Se;
        di2 = (yhat2(i+1).y-yhat2(i).y)*(Sdayy\(yhat2(i+1).y-yhat2(i).y)');                            
        di3(i) = (yhat2(i+1).y-yhat2(i).y)*(Sdayy\(yhat2(i+1).y-yhat2(i).y)');                            
        i = i+1;
    end
elseif strcmp(method,'MAP')
    %Maximum A Posterior solution
        Gy=(Sa*K')/((K*Sa*K')+Se);
        y_xa=K*xa';
        xhat=xa'+Gy*(y'-y_xa);
        %xhat = abs(xhat);       
        xi = xhat;
        xhat = xhat';
        Kflg=1;
        yhat1 = yhat;
        K1 = 1;
        [yhat,K,N]=ForwardModel(xhat,Kflg,setup);
        yhat = N.zs(2,:);
        K = K(sz(3)+1:2*sz(3),:);
elseif strcmp(method,'LS');
    xhat = ((K'*K)\K')*y';
    Kflg=1;
    xhat = xhat';
    [yhat,K,N]=ForwardModel(xhat,Kflg,setup);
    yhat = N.zs(2,:);
    yhat1 =1;
    K1 =1;
    K = K(sz(3)+1:2*sz(3),:);
end
S.Ss = ((K'*(Se^-1)*K +Sa^-1)^-1*(Sa\((K'*(Se^-1)*K +Sa^-1)^-1)));
S.Sm = ((K'*(Se^-1)*K +Sa^-1)^-1)*(K'*(Se\K))*((K'*(Se^-1)*K +Sa^-1)^-1);
S.Ss_plus_Ss = S.Ss+S.Sm;
if inputs.logswitch
    S.S = (K'*(Se^-1)*K+Sa^-1)^-1;%
else S.S = (K'*(Se^-1)*K +Sa^-1)^-1;
end
number_of_iterations = i;
% pass through Ss and times by g to obtain layer four smoothing errors.
end





