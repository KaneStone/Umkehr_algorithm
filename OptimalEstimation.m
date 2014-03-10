function [xhat,yhat,K,yhat1, K1, S, Sdayy]=OptimalEstimation(y,yhat,Se,xa,Sa,K,extra,method)

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
yhat (isnan(yhat)) = [];
y = reshape(y',1,numel(y));
y (isnan(y)) = [];

sz = size(extra.atmos.Apparent);
yhat1(1).a = yhat;
xa = xa';
xi = xa;
if strcmp(method,'Opt')
    for i = 1:3;
        K1(i).a = K;
        %reshaping into one vector for all wavelengths
        y = reshape(y',1,numel(y));
        yhat = reshape(yhat',1,numel(yhat));
        yhat (isnan(yhat)) = [];
        
        %5.8
        %xhat = xi + (inv(inv(Sa)+(K'/Se*K))\(K'/Se*(y'-yhat') - (Sa\(xi-xa))));
        
        %5.9 - N-form
        %xhat = xa + ((inv(Sa)+(K'/Se*K))\(K'/Se)*((y'-yhat')+K*(xi-xa)));        
        
        %5.10 - M-form  
        xhat = xa + Sa*K'*((K*Sa*K'+Se)\(y'-yhat'+K*(xi-xa)));
        
        %continue on with next iteration by calling forward model
        xi = xhat;
        xhat = xhat';
        Kflg = 1;
        AeroKflg = 0;
        [K,N]=ForwardModel(xhat,Kflg,AeroKflg,extra);
        yhat = N.zs;
        %yhat1(i).a = reshape(yhat',1,numel(yhat));
        yhat1(i).a = yhat;
        
        %%%%--Diagnostic testing for slow covergence--%%%%
        %Sdayy = Se*(K*Sa*K'+Se)\Se;
        %if i > 1;
        %    d2(i-1) = (yhat1(i).a - yhat1(i-1).a)/Sdayy*(yhat1(i).a-yhat1(i-1).a)';  
        %end
        %%%%------------------------------------------%%%%
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
        [yhat,K,N]=ForwardModel(xhat,Kflg,extra);
        yhat = N.zs(2,:);
        K = K(sz(3)+1:2*sz(3),:);
elseif strcmp(method,'LS');
    xhat = ((K'*K)\K')*y';
    Kflg=1;
    xhat = xhat';
    [yhat,K,N]=ForwardModel(xhat,Kflg,extra);
    yhat = N.zs(2,:);
    yhat1 =1;
    K1 =1;
    K = K(sz(3)+1:2*sz(3),:);
end
S = (K'*(Se^-1)*K +Sa^-1)^-1;
Sdayy = Se*((K*Sa*K'+Se)\Se);
end





