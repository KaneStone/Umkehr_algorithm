function [xhat,yhat,K,yhat1, K1, S]=OptimalEstimation(y,yhat,Se,xa,Sa,K,extra,method)

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
sz = size(extra.atmos.Apparent);
yhat1(1).a = yhat;
%xa = xa';
%load('xa1');
%xa = xa1*10;
%xa = xa'/1e11;
xa = xa';
xi = xa;
if strcmp(method,'Opt')
    for i = 1:1;

        K1(i).a = K;
        
        %5.8
        %xhat = xi + (inv(inv(Sa)+(K'/Se*K))\(K'/Se*(y'-yhat') - (Sa\(xi-xa))));
        
        %5.9
        %hat = xa + ((inv(Sa)+(K'/Se*K))\(K'/Se)*((y'-yhat')+K*(xi-xa)));
        
        %5.10
        xhat = xa + Sa*K'*((K*Sa*K'+Se)\(y'-yhat'+K*(xi-xa)));
       
        xi = xhat;
        xhat = xhat';
        %xhat1 = xhat*1e11;
        %for each iteration calculate yhat and Ki (turn on Kflg - the flag that 
        %means calcualte K)
        Kflg=1;
        [yhat,K,N]=ForwardModel(xhat,Kflg,extra);
        yhat = N.zs(2,:);
        yhat1(i+1).a = yhat;
        K = K(sz(3)+1:2*sz(3),:);
        
    %Decide whether the solution has converged (we can discuss different ways
    %of working this out - but not such a big issue as at least to start with
    %your problem will be with a weak absorber and a linear problem...
    end
elseif strcmp(method,'MAP')
    %Maximum A Posterior solution
        Gy=(Sa*K')/((K*Sa*K')+Se);
        %Gy = Sa*(K/(K'*Sa*K+Se));
        y_xa=K*xa';
        xhat=xa'+Gy*(y'-y_xa);
        %xhat = abs(xhat);       
        %Must recalculate the yhat with the new xhat
        %yhat=K*Xhat;
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
    %xhat = (K'/(K*K'))*y';
    Kflg=1;
    xhat = xhat';
    [yhat,K,N]=ForwardModel(xhat,Kflg,extra);
    yhat = N.zs(2,:);
    yhat1 =1;
    K1 =1;
    K = K(sz(3)+1:2*sz(3),:);
end
S = (K'*(Se^-1)*K +Sa^-1)^-1;
%S = Sa - Sa*K'*((Se+K*Sa*K')\(K*Sa));
end





