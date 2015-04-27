function cn = lte_gold_sequence( cinit,n )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%     x1 = zeros(1,n+Nc);

    Nc = 1600;
    %%初始化x1
    x1(1) = 1;
    x1(2:31) = 0;
    
    %%初始化x2
    for nn = 0:30
        x2(nn+1) = mod(cinit,2);
        cinit = floor(cinit/2);
    end
    
    for nn = 0:n+Nc-1
        x1(nn+1+31) = mod(x1(nn+1+3)+x1(nn+1),2);
        x2(nn+1+31) = mod(x2(nn+1+3)+x2(nn+1+2)+x2(nn+1+1)+x2(nn+1),2);
    end
    cn = mod(x1(n+1+Nc)+x2(n+1+Nc),2);
end

