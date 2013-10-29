function [] = plotWfunc(K,Apparent)

figure;

fig = gcf; 

sz = size(Apparent);

set(fig,'color','white','Position',get(0,'ScreenSize'));
subplot(1,3,1);
plot(K(1:sz(3),:),1:61);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dlogX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('A pair','fontsize',20);
%axis([-1e-3 5e-3 0 60]);

subplot(1,3,2);
plot(K(sz(3)+1:2*sz(3),:),1:61);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dlogX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('C pair','fontsize',20);
%axis([-.5e-3 2.5e-3 0 60]);

subplot(1,3,3);
plot(K(2*sz(3)+1:end,:),1:61);
set(gca,'fontsize',18);
xlabel('Jacobian dN/dlogX','fontsize',18);
ylabel('Altitude (km)','fontsize',18);
title('D pair','fontsize',20);
%axis([-.2e-3 1e-3 0 60]);


end