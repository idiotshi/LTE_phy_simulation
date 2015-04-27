%%
clc
clear all
n = 1;

for c = 0:5
    for b = 0:7
        for a = 0:11
            if (2^a)*(3^b)*(5^c) <= 1200
                if mod((2^a)*(3^b)*(5^c),12) == 0
                    seq(n) = (2^a)*(3^b)*(5^c);
                end
                n = n+1;
            end
        end
    end
end
q = unique(seq);
q = q(find(0< q));
stop
