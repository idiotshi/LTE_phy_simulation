function slot_fep_ul( LTE_DL_FRAME_PARMS,LTE_eNB_COMMON,l,Ns,eNB_id,no_prefix )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    l
    symbol = l + ((7-LTE_DL_FRAME_PARMS.Ncp)*(Ns & 1))
    
    dst_start = 1+LTE_DL_FRAME_PARMS.ofdm_symbol_size*symbol
    symbol0_src_start = 1+floor(LTE_DL_FRAME_PARMS.samples_per_tti/2)*Ns + LTE_DL_FRAME_PARMS.nb_prefix_samples0
    symbol_src_start = 1+floor(LTE_DL_FRAME_PARMS.samples_per_tti/2)*Ns + ...
                +(LTE_DL_FRAME_PARMS.ofdm_symbol_size+LTE_DL_FRAME_PARMS.nb_prefix_samples0+LTE_DL_FRAME_PARMS.nb_prefix_samples) ...
                +(LTE_DL_FRAME_PARMS.ofdm_symbol_size+LTE_DL_FRAME_PARMS.nb_prefix_samples)*(l-1)
    fft_size = LTE_DL_FRAME_PARMS.ofdm_symbol_size;
            
    for aa = 1:LTE_DL_FRAME_PARMS.nb_antennas_rx
        if l == 0
            LTE_eNB_COMMON.rxdataF(aa,dst_start:dst_start+fft_size-1) = fft(LTE_eNB_COMMON.rxdata(aa,symbol0_src_start:symbol0_src_start+fft_size-1));
        else
            LTE_eNB_COMMON.rxdataF(aa,dst_start:dst_start+fft_size-1) = fft(LTE_eNB_COMMON.rxdata(aa,symbol_src_start:symbol_src_start+fft_size-1));
        end
    end

end

