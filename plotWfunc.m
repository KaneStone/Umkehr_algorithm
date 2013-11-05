function [] = plotWfunc(K,Apparent)

figure;

fig = gcf; 

sz = size(Apparent);

set(fig,'color','white','Position',get(0,'ScreenSize'));

if sz(1) == 6;
    i = 3;
elseif sz(1) == 4;
    i = 2;
elseif sz(1) == 2;
    i = 1;
end

subplot(1,i,i/i);
plot(K(:,1:sz(3)),1:61);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('A pair','fontsize',20);
%axis([-1e-3 5e-3 0 60]);
if sz(1) == 2
    return
end
subplot(1,i,i/i+1);
plot(K(sz(3)+1:2*sz(3),:),1:61);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dlogX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('C pair','fontsize',20);
%axis([-.5e-3 2.5e-3 0 60]);
if sz(1) == 4;
    return
end
subplot(1,i,i/i+2);
plot(K(2*sz(3)+1:end,:),1:61);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dlogX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('D pair','fontsize',20);
%axis([-.2e-3 1e-3 0 60]);


end