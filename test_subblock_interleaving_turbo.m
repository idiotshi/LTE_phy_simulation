%%test sub-block interleaving for turbo
clc
clear all

D = 4 + floor(6144*rand);

bit_after_turbo = floor(2*rand(1,3*D));

w = subblock_interleaving_trubo(D,bit_after_turbo);


rate_matching_turbo
stop;