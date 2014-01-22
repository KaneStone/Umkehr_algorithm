function [Aeroxhat,yhat,K,yhat1,K1,S]=AerOptimalEstimation(y,yhat,Se,xa,Sa,K,extra)

%METHOD
%MAP = Maximum A posterior
%Opt = Optimal non-linear Gauss newton method
%LS = Least Squares

%OptimalEstimation function that solves the inversion of measurements given
%their errors, an a priori and associated error using a forward model 
%function that models the observations given the state vector. The formula 
%as given by Rodgers 1990 Pg 85 the Newtonian iteration allows for also a 
%non linear inversion:
%xi+1=xi+(Sa-1+KiTSe-1K)-1[KiTSe-1(y-yhat)-Sa-1(xi-xa)] %Eqn 5.8 or
%alternatively use equations 5.9 and 5.10

%Outputs 
%xhat - the retrieved state vector
%yhat - here the modeled SCDs or DSCDs
%K - the weighting functions

%Inputs
%y - measurement vector - N values
%Se - measurement error covariance matrix
%xa - a priori vector - climatology
%Sa - a priori covariance matrix

%Sa is the covariance between the a priori and
%Se is the covariance between the 

%non iterativ maximum a posteriori solution for linear problems
%Gy=Sa*(K/(K'*Sa*K+Se));
%y_xa=K'*xa;
%xhat=xa+Gy*(y-y_xa);

%for different wavelength pair vector length functionality
yhat = reshape(yhat',1,numel(yhat));
yhat (isnan(yhat)) = [];
y = reshape(y',1,numel(y));
y (isnan(y)) = [];

sz = size(extra.atmos.Apparent);
yhat1(1).a = yhat;
xa = xa';
xi = xa;
for i = 1:7;
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
    Aeroxhat = xa + Sa*K'*((K*Sa*K'+Se)\(y'-yhat'+K*(xi-xa)));
    % testing for slow convergence
    %Sdayy = Se*(K*Sa*K'+Se)\Se;
    %S = (K'*(Se^-1)*K +Sa^-1)^-1;
    %di2(i) = (yhat' - y')'/Sdayy*(yhat'-y');       
    xi = Aeroxhat;
    Aeroxhat = Aeroxhat';
    Aeromid = interp1(extra.atmos.Z,Aeroxhat,extra.atmos.Zmid,'linear','extrap');
    %for each iteration calculate yhat and Ki (turn on Kflg - the flag that 
    %means calculate K)
    Kflg = 0;
    AeroKflg = 1;
  
    extra.atmos.bMiept = (500./extra.lambda).^1.2*Aeroxhat;
    extra.atmos.bMie = (500./extra.lambda).^1.2*Aeromid;
    
    [K,N]=ForwardModel(extra.atmos.ozone,Kflg,AeroKflg,extra);
    yhat = N.zs;
    %yhat1(i).a = reshape(yhat',1,numel(yhat));
    yhat1(i).a = yhat;

    %testing for convergence
    Sdayy = Se*(K*Sa*K'+Se)\Se;
%         if i > 1;
%             d2(i-1) = (yhat1(i).a - yhat1(i-1).a)/Sdayy*(yhat1(i).a-yhat1(i-1).a)';  
%         end

%Decide whether the solution has converged (we can discuss different ways
%of working this out - but not such a big issue as at least to start with
%your problem will be with a weak absorber and a linear problem...
end
S = (K'*(Se^-1)*K +Sa^-1)^-1;
end