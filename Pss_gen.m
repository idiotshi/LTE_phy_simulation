function du = Pss_gen( u )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    n = 0:30;
    du1 = exp((-j*pi*u*n.*n+1)/63);
    n = 31:61;
    du2 = exp((-j*pi*u*(n+1).*(n+2))/63);
    du = [du1,du2];
end

