function [Se,Se_for_errors] = createSe(Apparent,scale_factor)

%Setting up measurement covariance matrix    

Apparent = reshape(Apparent',1,numel(Apparent));
Apparent_for_errors = reshape(Apparent',1,numel(Apparent));
Apparent (isnan(Apparent)) = [];

Init_SZA = [65,70,74,77,80,83,85,86.5,88,89,90,91,92,93,94,95];
Init_Var = [.15,.15,.15,.20,.25,.3,.35,.4,.7,1.4,2.8,4.6,9.2,18.4,36.8,73.6];
%Init_Var = [.15,.15,.15,.20,.25,.3,.35,.4,.7,1.4,2.8,4.6,4.6,4.6,4.6,4.6];

Se = interp1(Init_SZA,Init_Var,Apparent,'linear','extrap');
Se_for_errors = interp1(Init_SZA,Init_Var,Apparent_for_errors,'linear','extrap');
Se_for_errors (Apparent_for_errors <= 74) = .15;
Se (Apparent <= 74) = .15;
Se = diag(Se) .* scale_factor;
Se_for_errors = Se_for_errors .* scale_factor;
    
end