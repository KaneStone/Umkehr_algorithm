function [] = cloud_effect(I,intenstar,SZA,alts_to_perturb,SZA_to_perturb...
    ,lambda,rand_pert,norm_switch)
%Function to test cloud effects on the N-value curves
%cloud_effect(intensity_array,1:2,[lower_limit upper_limit])

figure;
fig = gcf;
set(fig,'color','white','position',[100 100 1000 700]);

col = [[0 0 0];[0 0 1];[1 0 0];[0 .7 0];[.7 0 .7]];

alts_to_perturb = [1,alts_to_perturb];

for i = 1:length(alts_to_perturb);
    
    intensity = I;
    %perturbing intensity 
    if i == 1;
        perturb_parameter = 0;
    else perturb_parameter = 1;
    end
    if strcmp(SZA_to_perturb,'all');
        intensity(:,1:alts_to_perturb(i),:) = I(:,1:alts_to_perturb(i),:)-I...
            (:,1:alts_to_perturb(i),:).*perturb_parameter; 
    else
        SZA_index = find(SZA >= SZA_to_perturb(1) & SZA <= SZA_to_perturb(2));
        intensity(:,1:alts_to_perturb(i),SZA_index) = I(:,1:alts_to_perturb(i),SZA_index)-I...
            (:,1:alts_to_perturb(i),SZA_index).*perturb_parameter; 
    end
    
    sz = size(SZA);
    ratio = zeros(sz(1),sz(2));
    
    %calculating intensity ratio with intenstar
    for j = 1:length(lambda);
        %for different wavelength pair vector length functionality
        find_nan = find(~isnan(SZA(ceil(j/2),:)));
        sz_ind = length(find_nan);
        for k = find_nan%1:sz_ind
            ratio(j,k)=sum(intensity(j,:,k).*intenstar(j,:,k))...
                ./sum(intenstar(j,:,k));
        end
    end
    
    %Calculating N-value
    N=zeros(length(lambda)/2,sz(2));
    wn = 1;
    for k = 1:length(lambda)/2;
        %ETSF = interp1(atmos.solar(:,1),atmos.solar(:,2),...
        %    lambda(wn:wn+1),'linear','extrap');  
        ETSF_ratio = 1; %ETFS is removed by normalising to lowest SZA
        N(k,:) = 100*log10(ETSF_ratio*ratio(wn+1,:)./ratio(wn,:));    
        wn = wn+2;
    end

    %plotting effect before normalisation
    %set(gcf,'color','white','position',[100 100 1000 700]);
    ph(i) = plot(SZA,N,'color',col(i,:),'LineWidth',2');    
    hold on
    if i == 1
        ylabel('N-value','fontsize',20);
        xlabel('SZA','fontsize',20);
        set(gca,'fontsize',18);
        title('N-value changes','fontsize',22);
    end

    %normalising simulated N-values to lowest SZA.
    if norm_switch
        [~, SZA_min_location] = min(SZA,[],2);
        for j = 1:length(SZA_min_location);
             N_min = N(j,SZA_min_location(j));
            N(j,:) = N(j,:) - repmat(N_min,1,sz(2));   
        end
    end
    ph2(i) = plot(SZA,N,'--','color',col(i,:),'LineWidth',2);    
    clearvars ratio N intensity
end


lh = legend([ph(1) ph2(1) ph(2) ph(3) ph(4)],'Before Normalisation - no pert'...
    ,'After Normalisation - no pert','1km pert','1-3km pert','1-10km pert');
set(lh,'location','NorthWest','fontsize',18);
file = '/Users/stonek/work/Dobson/OUTPUT/test_cloud.eps';
export_fig(file,'-eps');

end