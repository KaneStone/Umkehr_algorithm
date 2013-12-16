function [Se Se_for_errors] = createSe(Apparent)
    
%INCORRECT
    Apparent = reshape(Apparent',1,numel(Apparent));
    Apparent_for_errors = reshape(Apparent',1,numel(Apparent));
    Apparent (isnan(Apparent)) = [];
    
    Init_SZA = [65,70,74,77,80,83,85,86.5,88,89,90,91,92,93,94,95];
    %TRY WITH CONSTANT VALUES
    Init_Var = [.15,.15,.15,.20,.25,.3,.35,.4,.7,1.4,2.8,4.6,9.2,18.4,36.8,73.6];
    %Init_Var = [.15,.15,.15,.15,.15,.15,.15,.15,.15,.15,.15,.15,.15,.15,.15,.15];
    %Se = zeros(1,length(Apparent));    
    %This may not be needed.
    sz = size(Apparent);
    if sz(1) == 3
        Apparent = horzcat(Apparent(1,:),Apparent(2,:),Apparent(3,:));
    elseif sz(1) == 2
        Apparent = horzcat(Apparent(1,:),Apparent(2,:));
    end
    
    Se = interp1(Init_SZA,Init_Var,Apparent,'linear','extrap');
    Se_for_errors = interp1(Init_SZA,Init_Var,Apparent_for_errors,'linear','extrap');
    Se_for_errors (Apparent_for_errors <= 74) = .15;
    Se (Apparent <= 74) = .15;
    Se = diag(Se)*20;
    Se_for_errors = Se_for_errors*20;
    
end