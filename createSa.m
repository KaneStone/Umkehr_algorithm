function Sa = createSa(setup, inputs)
%Setup for different types of covariance matrices.
    
%predefining Sa size

Sa = zeros(setup.atmos.nlayers, setup.atmos.nlayers);

[~, ozonemaxindex] = max(setup.atmos.ozone);

%scale upper altitudes
scale = ones(1,setup.atmos.nlayers);
scaleupperindex = find(setup.atmos.Z == (ozonemaxindex * (inputs.dz / 1000) + 10) * 1000);
scaleupperindex2 = find(setup.atmos.Z == setup.atmos.Z(end));
scaleupperlayers = scaleupperindex2 - scaleupperindex;
scaleupper = 1:9 / scaleupperlayers:10;

%scale lower altitudes    
scalelowerindex = find(setup.atmos.Z == (ozonemaxindex * (inputs.dz / 1000) - 10) * 1000);    
scalelower = 15:-14 / (scalelowerindex-1):1;
scale(scaleupperindex:end) = [scaleupper,repmat(scaleupper(end),1,...
    setup.atmos.nlayers - scaleupperindex2)];
scale(1:scalelowerindex) = scalelower;
    
if strcmp(inputs.covariance_type,'full_covariance_constant')
    %Uses constant values in the region of largest ozone and scales
    %elsewhere (user defined version of "full_covariance")
    
    C = .1;
    Sa_temp = 5e11 ./ scale * inputs.Sa_scalefactor;
    for k = 1:length(setup.atmos.Z)
        for j = 1:length(setup.atmos.Z)                     
            Sa(k,j) = C * Sa_temp(k) * Sa_temp(j) * exp(-(abs(k - j)) / 5);
        end
    end            
    
elseif strcmp(inputs.covariance_type,'full_covariance')
    % Scales values based on ozone concentration
    
    C = .1;   
    Sa_temp = setup.atmos.ozone;
    [~,minindex] = min(Sa_temp(1:20));
    %Sa_temp (Sa_temp <= 3e11) = 3e11;
    Sa_temp = Sa_temp+3e11;
    Sa_temp(1:minindex) = Sa_temp(minindex);
    Sa_temp = Sa_temp.*2;
    for k = 1:length(setup.atmos.Z)        
        for j = 1:length(setup.atmos.Z)         
            Sa(k,j) = C * Sa_temp(k) * Sa_temp(j) * exp( - (abs(k - j)) / 7);           
        end
    end    
    
elseif strcmp(inputs.covariance_type,'full_covarianceSD')
    % Scales values based on ozone standard deviations.
    
    C = .1;   
    Sa_temp = setup.atmos.ozoneSD;        
    for k = 1:length(setup.atmos.Z)        
        for j = 1:length(setup.atmos.Z)            
            Sa(k,j) = C * Sa_temp(k) * Sa_temp(j) * exp( - (abs(k - j)) / 5);           
        end
    end    
    
elseif strcmp(inputs.covariance_type,'diagonal_constant')    
    % Diagonal covariance (no covariance) matrix 
    % Uses constant values in the region of largest ozone  
    
    C = .1;
    Sa_temp = 5e11 ./ scale * inputs.Sa_scalefactor;    
    Sa = diag(C * Sa_temp .* Sa_temp);    
    
elseif strcmp(inputs.covariance_type,'diagonal')    
    % Diagonal covariance (no covariance) matrix 
    % Uses constant values in the region of largest ozone  
    
    C = .1;
    Sa_temp = setup.atmos.ozone;
    [~,minindex] = min(Sa_temp(1:20));
    Sa_temp (Sa_temp <= 3e11) = 3e11;
    Sa_temp(1:minindex) = Sa_temp(minindex);    
    Sa = diag(C * Sa_temp .* Sa_temp);    

elseif strcmp(inputs.covariance_type,'diagonalSD')
    % Diagonal covariance (no covariance) using input standard deviations
    
    SD = setup.atmos.ozoneSD;
    Sa_temp = SD*inputs.Sa_scalefactor;
    Sa_temp (Sa_temp <= 1e11) = 1e11;
    Sa = diag(Sa_temp,0).^2;
    
end

end

