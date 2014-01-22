function Sa = createSaAer
    Sa = (ones(1,81)*1e-16);
    Sa(1,31:end) = 0;
    Sa = diag(Sa);
end

