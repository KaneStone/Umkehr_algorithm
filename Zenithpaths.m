function [zs, atmos] = Zenithpaths(atmos,Umkehr,lambda,,dz,plot_pathlength)
 
%This function calculates the zenith ray paths. The SZAs that are given in
%the measurements are calculated from time, and are thus are the true SZAs. To
%calcualte the Zenith paths, Apparent SZAs are needed. Initial apparent 
%SZAs are setup that confine the measurements. The initial SZAs are used 
%to calculate initial true SZAs. Then through interpolation, actual 
%apparent SZAs are calculated. 

a = Umkehr.data.SolarZenithAngle;

%setting up initial apparent SZA.
mx = ceil(max(a(:)));
mn = floor(min(a(:)));

Apparent = mn:1:mx; 
al = length(Apparent);

%predefining array sizes
Apparent_Final = zeros(length(lambda), atmos.nlayers-1, length(a));
zs = ones(length(lambda), length(a), atmos.nlayers-1, atmos.nlayers-1)*1000; 
True.Initial = zeros(length(lambda), atmos.nlayers-1, length(Apparent));
Apparent_Initial = zeros(length(lambda), atmos.nlayers-1, length(Apparent));

sz_a = size(a);

for iteration = 1:2;
    for i = 1:length(lambda)  
        cwlp = ceil(.5*i);
        gamma = (atmos.radius./atmos.N(i,:)).*(atmos.dndz(i,:)); %dndz is defined as negative dndr
        %gamma = (atmos.r./atmos.N(i,:)).*(atmos.dndr(i,:));
        for iscat = 1:atmos.nlayers-1
            if iteration == 2            
                True.actual = a;
                True_I = reshape(True.Initial(i,iscat,:),1,al);
                True_I (True_I == 0) = [];                
                Apparent = interp1(squeeze(True_I)...
                    ,squeeze(Apparent_Initial(i,iscat,1:length(True_I)))...
                    ,True.actual(cwlp,:),'linear','extrap');
              
            end        
            for j = 1:length(Apparent) 
                if Apparent(j) > 90                 
                    [True, Apparent_Initial, Apparent_Final, zs, atmos] =...
                        zenithpaths_tangent(atmos,i,j,True,Apparent_Initial...
                        ,Apparent_Final,Apparent,iscat,gamma,zs,dz,iteration);  
                else [True, Apparent_Initial, Apparent_Final, zs] =...
                        zenithpaths_down(atmos,i,j,True,Apparent_Initial...
                        ,Apparent_Final,Apparent,iscat,gamma,zs,dz,iteration);  
                end
            end
        end 
    end
end

atmos.Apparent = Apparent_Final;
atmos.true_actual = True.actual;

%plotting path length 
if plot_pathlength
    SZAnumber = 1;
    figure
    set(gcf,'color','white','position',[100 100 1000 700]);
    plot(squeeze(zs(1,SZAnumber ,1,:)));
    title(strcat('SZA =','{ }', num2str(Apparent(SZAnumber))),'fontsize',20);
    ylabel('layer path (m)','fontsize',20);
    xlabel('layer no.','fontsize',20);
    export_fig(strcat('/Users/stonek/Dropbox/Work_Share/Dobson_Umkehr/Figures/'...
        ,num2str(Apparent(SZAnumber)),'.png'),'-png');
    close gcf
end
end

function [True, Apparent_Initial, Apparent_Final, zs, atmos] = ...
    zenithpaths_tangent(atmos,i,j,True,Apparent_Initial,Apparent_Final,...
    Apparent,iscat,gamma,zs,dz,iteration)                    
%Calculates zenith paths when theta is greater than 90

%Rg(iscat) = atmos.Nr(i,iscat)*sind(Apparent(j));
Rg = ones(1,length(atmos.N(i,1:atmos.nlayers-1))).*...
    atmos.Nr(i,iscat)*sind(Apparent(j)); 
atmos.ztan = interp1(atmos.Nr(i,:),atmos.radius,Rg(iscat),'linear','extrap');

tanlayer = ceil(((atmos.ztan-atmos.radius(1))/dz));

if tanlayer < 1
    %Setting zenith path to zero if tangent point is below Earth's surface
     if iteration == 2
         zs(i,j,iscat,:) = 0;
     end
    return
end    

%just below the scattering point to just above the tangent layer. 
b = atmos.radius(tanlayer+1:iscat-1);
a = b+dz;
x2 = ((1./atmos.N(i,tanlayer+1:iscat-1)).*...
    sqrt(atmos.N(i,tanlayer+1:iscat-1).^2.*b.^2-Rg(tanlayer+1:iscat-1).^2));
x1 = ((1./atmos.N(i,tanlayer+2:iscat)).*...
    sqrt(atmos.N(i,tanlayer+2:iscat).^2.*a.^2-Rg(tanlayer+2:iscat).^2));
dx = abs(x2-x1);
phi2 = (atmos.N(i,tanlayer+1:iscat-1).*Rg(tanlayer+1:iscat-1))./...
    ((atmos.N(i,tanlayer+1:iscat-1).^2).*(b.^2)-...
    (gamma(tanlayer+1:iscat-1).*Rg(tanlayer+1:iscat-1).^2));
phi1 = (atmos.N(i,tanlayer+2:iscat).*Rg(tanlayer+2:iscat))./...
    ((atmos.N(i,tanlayer+2:iscat).^2).*(a.^2)-...
    (gamma(tanlayer+2:iscat).*Rg(tanlayer+2:iscat).^2));

if iteration == 2
    
    ds2 = ((atmos.N(i,tanlayer+1:iscat-1).^2).*(b.^2))./...
       ((atmos.N(i,tanlayer+1:iscat-1).^2).*...
       (b.^2)-(gamma(tanlayer+1:iscat-1).*(Rg(tanlayer+1:iscat-1).^2)));
    ds1 = ((atmos.N(i,tanlayer+2:iscat).^2).*(a.^2))./...
       ((atmos.N(i,tanlayer+2:iscat).^2).*...
       (a.^2)-(gamma(tanlayer+2:iscat).*Rg(tanlayer+2:iscat).^2));       
    
    %ds1 = ones(1,length(tanlayer+1:iscat-1))./(1-(gamma(tanlayer+1:iscat-1).*sind(Apparent(j)).*2));
    %ds2 = ones(1,length(tanlayer+1:iscat-1))./(1-(gamma(tanlayer+1:iscat-1).*sind(Apparent(j)).*2));
    
    zs(i,j,iscat,tanlayer+1:iscat-1) = dz+(dx.*(ds1+ds2));
end
phi_down = dx*((phi1+phi2)/2)'.*(180/pi)*2;

%tangent layer calculation here:
a = atmos.radius(tanlayer+1);
b = atmos.ztan;
x1 = ((1/atmos.N(i,tanlayer+1))*sqrt(atmos.N(i,tanlayer+1)^2*a^2-Rg(tanlayer)^2));
x2 = 0;
dx = abs(x2-x1);

if iteration == 1
    gtan = gamma(1);
    phi1 = (atmos.N(i,tanlayer)*Rg(tanlayer))/((atmos.N(i,tanlayer)^2)*(a^2)-(gamma(tanlayer)*...
        (Rg(tanlayer)^2)));
    phi2 = (Rg(tanlayer)^2/atmos.ztan)/((Rg(tanlayer)^2/atmos.ztan^2)*(b^2)-...
        (gtan*(Rg(tanlayer)^2)));  
    phi_tangent = (dx*((phi1+phi2)/2))*(180/pi)*2;  
end
if iteration == 2
    gtan = interp1(atmos.radius,gamma,atmos.ztan,'linear','extrap');    
    ds1 = ((atmos.N(i,tanlayer+1).^2).*(a.^2))./...
       ((atmos.N(i,tanlayer+1).^2).*...
       (a.^2)-(gamma(tanlayer+1).*Rg(tanlayer+1).^2));  
    ds2 = (((Rg(tanlayer)/atmos.ztan)^2)*(b^2))/...
        (((Rg(tanlayer)/atmos.ztan)^2)*...
         (b^2)-(gtan*Rg(tanlayer)^2));
    zs(i,j,iscat,tanlayer) = dz+(dx.*(ds1+ds2));        
end

%calculation after tangent when light goes up
a = atmos.radius(iscat:atmos.nlayers-1);
b = a+dz;
x1 = ((1./atmos.N(i,iscat:atmos.nlayers-1)).*...
    sqrt(atmos.N(i,iscat:atmos.nlayers-1).^2.*a.^2-Rg(iscat:atmos.nlayers-1).^2));
x2 = ((1./atmos.N(i,iscat+1:atmos.nlayers)).*...
    sqrt(atmos.N(i,iscat+1:atmos.nlayers).^2.*b.^2-Rg(iscat:atmos.nlayers-1).^2));
dx = abs(x2-x1);
phi1 = (atmos.N(i,iscat:atmos.nlayers-1).*Rg(iscat:atmos.nlayers-1))./...
    ((atmos.N(i,iscat:atmos.nlayers-1).^2).*(a.^2)-...
    (gamma(iscat:atmos.nlayers-1).*Rg(iscat:atmos.nlayers-1).^2));
phi2 = (atmos.N(i,iscat+1:atmos.nlayers).*Rg(iscat:atmos.nlayers-1))./...
    ((atmos.N(i,iscat+1:atmos.nlayers).^2).*(b.^2)-...
    (gamma(iscat+1:atmos.nlayers).*Rg(iscat:atmos.nlayers-1).^2));

phi_up = dx*((phi1+phi2)./2)'.*(180/pi);

if iteration == 2
    ds1 = ((atmos.N(i,iscat:atmos.nlayers-1).^2).*(a.^2))./...
       ((atmos.N(i,iscat:atmos.nlayers-1).^2).*...
       (a.^2)-(gamma(iscat:atmos.nlayers-1).*(Rg(iscat:atmos.nlayers-1).^2)));
    ds2 = ((atmos.N(i,iscat+1:atmos.nlayers).^2).*(b.^2))./...
       ((atmos.N(i,iscat+1:atmos.nlayers).^2).*...
       (b.^2)-(gamma(iscat+1:atmos.nlayers).*(Rg(iscat:atmos.nlayers-1).^2)));       
    
    %ds1 = ones(1,length(iscat:atmos.nlayers-1))./(1-(gamma(iscat:atmos.nlayers-1).*sind(Apparent(j)).*2));
    %ds2 = ones(1,length(iscat:atmos.nlayers-1))./(1-(gamma(iscat+1:atmos.nlayers).*sind(Apparent(j)).*2));
    
    zs(i,j,iscat,iscat:atmos.nlayers-1) = dx.*(ds1+ds2)/2;
end

if iteration == 1
    phi_total = phi_down+phi_up+phi_tangent;
    AngleTOA = asind(Rg(iscat)/atmos.Nr(i,end));
    Apparent_Initial(i,iscat,j) = Apparent(j);
    True.Initial(i,iscat,j) = AngleTOA+phi_total;
else
    Apparent_Final(i,iscat,j) = Apparent(j);
end
end            

function [True, Apparent_Initial, Apparent_Final, zs] = ...
    zenithpaths_down(atmos,i,j,True,Apparent_Initial,Apparent_Final,...
    Apparent,iscat,gamma,zs,dz,iteration)
%Calculates down through the atmosphere for cases where theta is less than 90           

Rg = ones(1,length(atmos.N(i,iscat:atmos.nlayers-1))).*...
    atmos.Nr(i,iscat)*sind(Apparent(j)); 


%layers above the scattering height which are the slant paths  
a = atmos.radius(iscat:atmos.nlayers-1);
b = a+dz;
x1 = ((1./atmos.N(i,iscat:atmos.nlayers-1)).*...
    sqrt(atmos.N(i,iscat:atmos.nlayers-1).^2.*a.^2-Rg.^2));

x2 = ((1./atmos.N(i,iscat+1:atmos.nlayers)).*...
    sqrt(atmos.N(i,iscat+1:atmos.nlayers).^2.*b.^2-Rg.^2));
dx = abs(x2-x1);
phi1 = (atmos.N(i,iscat:atmos.nlayers-1).*Rg)./...
    ((atmos.N(i,iscat:atmos.nlayers-1).^2).*(a.^2)-...
    (gamma(iscat:atmos.nlayers-1).*Rg.^2));
phi2 = (atmos.N(i,iscat+1:atmos.nlayers).*Rg)./...
    ((atmos.N(i,iscat+1:atmos.nlayers).^2).*(b.^2)-...
    (gamma(iscat+1:atmos.nlayers).*Rg.^2));

phi = dx*((phi1+phi2)./2)'.*(180/pi);

if iteration == 2
                   
     ds1 = (atmos.Nr(i,iscat:atmos.nlayers-1).^2)./...
        ((atmos.Nr(i,iscat:atmos.nlayers-1).^2)...
        -(gamma(iscat:atmos.nlayers-1).*(Rg.^2)));            

     ds2 = (atmos.Nr(i,iscat+1:atmos.nlayers).^2)./...
        ((atmos.Nr(i,iscat+1:atmos.nlayers).^2)...
        -(gamma(iscat+1:atmos.nlayers).*(Rg.^2)));            
    
    zs(i,j,iscat,iscat:atmos.nlayers-1) = dx.*(ds1+ds2)/2;
end

if iteration == 1
    AngleTOA = asind(Rg(1)/atmos.Nr(i,end));
    Apparent_Initial(i,iscat,j) = Apparent(j);
    True.Initial(i,iscat,j) = AngleTOA+phi;
else
    Apparent_Final(i,iscat,j) = Apparent(j);
end    
end            
