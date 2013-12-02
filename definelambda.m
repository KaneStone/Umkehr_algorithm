function [lambda] = definelambda(wl,test,atmos)
    %This function defines lambda based of what WLP are used and what is
    %available.

existing_WLP = atmos.N_values(test).WLP;
count = 1;
for i = 1:length(existing_WLP);
    if (existing_WLP(i) == 'A')
        lambda(count) = wl.a(1);
        lambda(count+1) = wl.a(2);
    elseif (existing_WLP(i) == 'C')
        lambda(count) = wl.c(1);
        lambda(count+1) = wl.c(2);
    elseif (existing_WLP(i) == 'D')
        lambda(count) = wl.d(1);
        lambda(count+1) = wl.d(2);
    end   
    count = count+2;
end
lambda = lambda';
end