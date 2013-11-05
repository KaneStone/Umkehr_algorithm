function [zs atmos] = Zenithpaths(atmos,lambda,test)

% This needs to be generalised
 
a = atmos.initial_SZA(test).SZA;
a (isnan(a)) = [];
%Two lines below may cause problems
mx = ceil(max(a(:)));
mn = floor(min(a(:)));
Apparent = mn:1:mx;
al = length(Apparent);
Apparent_Final = zeros(length(lambda), atmos.nlayers-1, length(a));
zs = ones(length(lambda), length(a), atmos.nlayers-1, atmos.nlayers-1)*1000; 
True.Initial = zeros(length(lambda), atmos.nlayers-1, length(Apparent));
Apparent_Initial = zeros(length(lambda), atmos.nlayers-1, length(Apparent));


for iteration = 1:2;
    for i = 1:length(lambda)  
        cwlp = ceil(.5*i);
        gamma = (atmos.r/atmos.N(i,:))*(atmos.dndz(i,:));
        for iscat = 1:atmos.nlayers-1
            if iteration == 2            
                True.actual = a; %just picked one from random
                True.actual (isnan(True.actual)) = [];
                True_I = reshape(True.Initial(i,iscat,:),1,al);
                True_I (True_I == 0) = [];
                Apparent = interp1(squeeze(True_I)...
                    ,squeeze(Apparent_Initial(i,iscat,1:length(True_I))),True.actual(cwlp,:),'linear','extrap');

            end        
            for j = 1:length(Apparent) 
                if Apparent(j) > 90                 
                    [True Apparent_Initial Apparent_Final zs atmos] =...
                        zenithpaths_tangent(atmos,i,j,True,Apparent_Initial...
                        ,Apparent_Final,Apparent,iscat,gamma,zs,iteration);  
                else [True Apparent_Initial Apparent_Final zs] =...
                        zenithpaths_down(atmos,i,j,True,Apparent_Initial...
                        ,Apparent_Final,Apparent,iscat,gamma,zs,iteration);  
                end
            end
        end 
    end
end

atmos.Apparent = Apparent_Final;
atmos.true_actual = True.actual;
end

function [True Apparent_Initial Apparent_Final zs atmos] = zenithpaths_tangent(atmos,i,j,True...
    ,Apparent_Initial,Apparent_Final,Apparent,iscat,gamma,zs,iteration)                    

Rg(iscat) = atmos.Nr(i,iscat)*sind(Apparent(j)); %(Meant to be 180-Apparent)
atmos.ztan = interp1(atmos.Nr(i,:),atmos.r,Rg(iscat),'linear','extrap');
tanlayer = ceil(((atmos.ztan-atmos.r(1))/atmos.dz));

%if tanlayer is less than one shouldn't the zenith path be zero not 1000
if tanlayer < 1
    %zs(i,j,iscat,:) = 0;
    return
end    

for l = iscat-1:-1:tanlayer+1; %just below the scattering point to just above the tangent layer.  
    a = atmos.r(l+1);
    b = atmos.r(l);
    x1 = ((1/atmos.N(i,l+1))*sqrt(atmos.N(i,l+1)^2*a^2-Rg(iscat)^2));
    x2 = ((1/atmos.N(i,l))*sqrt(atmos.N(i,l)^2*b^2-Rg(iscat)^2));
    dx = abs(x2-x1);
    phi1 = (atmos.N(i,l+1)*Rg(iscat))/((atmos.N(i,l+1)^2)*(a^2)-(gamma(l+1)*(Rg(iscat)^2)));
    phi2 = (atmos.N(i,l)*Rg(iscat))/((atmos.N(i,l)^2)*(b^2)-(gamma(l)*(Rg(iscat)^2)));  
    
    if iteration == 2
        ds1 = ((atmos.N(i,l+1)^2)*(a^2))/((atmos.N(i,l+1)^2)*(a^2)-(gamma(l+1)*(Rg(iscat)^2)));
        ds2 = ((atmos.N(i,l)^2)*(b^2))/((atmos.N(i,l)^2)*(b^2)-(gamma(l)*(Rg(iscat)^2)));
        zs(i,j,iscat,l) = atmos.dz+dx*(ds1+ds2); %Needs to be changed for tangent symmetry
    end
        phi(l) = (dx*((phi1+phi2)/2))*(180/pi)*2;                         
end    

%tangent layer calculation here!
l = tanlayer;
a = atmos.r(l+1);
b = atmos.ztan;
x1 = ((1/atmos.N(i,l+1))*sqrt(atmos.N(i,l+1)^2*a^2-Rg(iscat)^2));
x2 = 0;
dx = abs(x2-x1);
phi1 = (atmos.N(i,l)*Rg(iscat))/((atmos.N(i,l)^2)*(a^2)-(gamma(l)*(Rg(iscat)^2)));
phi2 = (Rg(iscat)^2/atmos.ztan)/((Rg(iscat)^2/atmos.ztan^2)*(b^2)-(gamma(1)*(Rg(iscat)^2)));     
phi(l) = (dx*((phi1+phi2)/2))*(180/pi)*2;  

if iteration == 2
    gtan = interp1(atmos.r,gamma,atmos.ztan,'linear','extrap');
    ds1 = ((atmos.N(i,l+1)^2)*(a^2))/((atmos.N(i,l+1)^2)*(a^2)-(gamma(l+1)*Rg(iscat)^2));
    ds2 = (((Rg(iscat)/atmos.ztan)^2)*(b^2))/(((Rg(iscat)/atmos.ztan)^2)*(b^2)-(gtan*Rg(iscat)^2));
    zs(i,j,iscat,l) = atmos.dz+dx*(ds1+ds2); % needs to be changed for tangent symmetry
end

for l = iscat:atmos.nlayers-1; %calculation after tangent when light goes up
    a = atmos.r(l);
    b = a+atmos.dz;
    x1 = ((1/atmos.N(i,l))*sqrt(atmos.N(i,l)^2*a^2-Rg(iscat)^2));
    x2 = ((1/atmos.N(i,l+1))*sqrt(atmos.N(i,l+1)^2*b^2-Rg(iscat)^2));
    dx = abs(x2-x1);
    phi1 = (atmos.N(i,l)*Rg(iscat))/((atmos.N(i,l)^2)*(a^2)-(gamma(l)*(Rg(iscat)^2)));
    phi2 = (atmos.N(i,l+1)*Rg(iscat))/((atmos.N(i,l+1)^2)*(b^2)-(gamma(l+1)*(Rg(iscat)^2)));           
    
    if iteration == 2
        ds1 = ((atmos.N(i,l)^2)*(a^2))/((atmos.N(i,l)^2)*(a^2)-(gamma(l)*(Rg(iscat)^2)));
        ds2 = ((atmos.N(i,l+1)^2)*(b^2))/((atmos.N(i,l+1)^2)*(b^2)-(gamma(l+1)*(Rg(iscat)^2)));
        zs(i,j,iscat,l) = dx*(ds1+ds2)/2;
    end    
    phi(l) = (dx*((phi1+phi2)/2))*(180/pi);                               
end    

if iteration == 1
    phi_total = sum(phi);
    AngleTOA = asind(Rg(iscat)/atmos.Nr(i,end));
    Apparent_Initial(i,iscat,j) = Apparent(j);
    True.Initial(i,iscat,j) = AngleTOA+phi_total;
else
    Apparent_Final(i,iscat,j) = Apparent(j);
end
end            


function [True Apparent_Initial Apparent_Final zs] = zenithpaths_down(atmos,i,j,True,...
    Apparent_Initial,Apparent_Final,Apparent,iscat,gamma,zs,iteration)
%Calculates down through the atmosphere for cases where theta is less than 90                             
    Rg(iscat) = atmos.Nr(i,iscat)*sind(Apparent(j));
     
for l = iscat:atmos.nlayers-1; %layers above the scattering height which are the slant paths  
    a = atmos.r(l);
    b = a+atmos.dz;
    x1 = ((1/atmos.N(i,l))*sqrt(atmos.N(i,l)^2*a^2-Rg(iscat)^2));
    x2 = ((1/atmos.N(i,l+1))*sqrt(atmos.N(i,l+1)^2*b^2-Rg(iscat)^2));
    dx = abs(x2-x1);
    phi1 = (atmos.N(i,l)*Rg(iscat))/((atmos.N(i,l)^2)*(a^2)-(gamma(l)*(Rg(iscat)^2)));
    phi2 = (atmos.N(i,l+1)*Rg(iscat))/((atmos.N(i,l+1)^2)*(b^2)-(gamma(l+1)*(Rg(iscat)^2)));  
    
    if iteration == 2
        ds1 = ((atmos.N(i,l)^2)*(a^2))/((atmos.N(i,l)^2)*(a^2)-(gamma(l)*(Rg(iscat)^2)));
        ds2 = ((atmos.N(i,l+1)^2)*(b^2))/((atmos.N(i,l+1)^2)*(b^2)-(gamma(l+1)*(Rg(iscat)^2)));
        zs(i,j,iscat,l) = dx*(ds1+ds2)/2;
    end
    
    if iteration == 1
        if l == iscat                                        
            phi(l) = (dx*((phi1+phi2)/2))*(180/pi);               
        else
             phi(l) = phi(l-1)+((dx*((phi1+phi2)/2))*(180/pi));
        end
    end

end

if iteration == 1
    AngleTOA = asind(Rg(iscat)/atmos.Nr(i,end));
    Apparent_Initial(i,iscat,j) = Apparent(j);
    True.Initial(i,iscat,j) = AngleTOA+phi(end);
else
    Apparent_Final(i,iscat,j) = Apparent(j);
end
end            
