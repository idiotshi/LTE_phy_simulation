function [w,R_TC_subblock]= subblock_interleaving_trubo( D,d)
    %%D is the bit size of each bit seq after turbo
    %% d is the bit seq with size 3*D
    
    %%turbo 编码后的输出bit流为三路，大小均为D，根据36.212 5.1.4.1节，第1,2路的交织方式相同，第3路采用单独的交织方式
    input = reshape(d,3,D);
    
    C_TC_subblock = 32;
    R_TC_subblock = ceil(D/32);
    
    pattern = [0 16 8 24 4 20 12 28 2 18 10 26 6 22 14 30 1 17 9  25 5 21 13 29 3 19 11 27 7 23 15 31];
    
    tmp = zeros(3,C_TC_subblock*R_TC_subblock);
    
%     if C_TC_subblock*R_TC_subblock > D
    N_D =  C_TC_subblock*R_TC_subblock - D;
    tmp(1,1:N_D) = -1;%%-1 表示NULL
    tmp(1,N_D+1:N_D+D) = input(1,:);
    
    tmp(2,1:N_D) = -1;
    tmp(2,N_D+1:N_D+D) = input(2,:);
       
    tmp(3,1:N_D) = -1;
    tmp(3,N_D+1:N_D+D) = input(3,:);
    
    %%for bit seq 1,2
    tmp2_seq1 = reshape(tmp(1,:),R_TC_subblock,C_TC_subblock);
    tmp2_seq2 = reshape(tmp(1,:),R_TC_subblock,C_TC_subblock);
    
    tmp3_seq1 = zeros(R_TC_subblock,C_TC_subblock);
    tmp3_seq2 = zeros(R_TC_subblock,C_TC_subblock);
    for n = 1:C_TC_subblock
        tmp3_seq1(:,n) = tmp2_seq1(:,pattern(n)+1);
        tmp3_seq2(:,n) = tmp2_seq2(:,pattern(n)+1);
    end
    
    %%for bit seq 3
    pi_k = zeros(1,R_TC_subblock*C_TC_subblock);
    for k = 0:R_TC_subblock*C_TC_subblock-1
        pi_k(k+1) = mod(pattern(1+floor(k/R_TC_subblock))+C_TC_subblock*mod(k,R_TC_subblock)+1,R_TC_subblock*C_TC_subblock);
    end
    
    tmp3_seq3 = tmp(3,1+pi_k);
    
    %%output 36.212 5.1.4.1.2 circular buffer
    w(1:R_TC_subblock*C_TC_subblock) = reshape(tmp3_seq1,1,R_TC_subblock*C_TC_subblock);
    w(R_TC_subblock*C_TC_subblock+1:2:3*R_TC_subblock*C_TC_subblock) = reshape(tmp3_seq2,1,R_TC_subblock*C_TC_subblock);
    w(R_TC_subblock*C_TC_subblock+2:2:3*R_TC_subblock*C_TC_subblock) = tmp3_seq3; 
end

