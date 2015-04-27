function ncs_cell = init_ncs_cell( frame_parms)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

    %%一个时隙内的ofdm符号个数，是否考虑SRS?
    N_UL_symb = 7 - frame_parms.Ncp;
    
    ncs_cell = zeros(20,N_UL_symb);
    tmp = 0;
    for ns = 0:19
        for l = 0:N_UL_symb-1
            for i = 0:7
                s = lte_gold_sequence(frame_parms.Nid_cell,(8*N_UL_symb*ns+8*l+i)*2^i);
                tmp = tmp+s;
            end
            ncs_cell(ns+1,l+1) = tmp;
        end
    end
end

