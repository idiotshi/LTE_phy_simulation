function phy_ue_tx( PHY_VARS_UE )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    %%======================测试参数赋值======================%%
    %%测试PUCCH发送
    pucch = 1;
    
    %%======================测试参数赋值======================%%
    
    phy_vars_ue = PHY_VARS_UE;
    frame_parms = PHY_VARS_UE.LTE_DL_FRAME_PARMS;
    
    slot_tx = phy_vars_ue.slot_tx;
    subframe_tx = slot_tx/2;
    frame_tx = phy_vars_ue.frame_tx;
    
    if mod(slot_tx,2) == 0
        %%功率？
        if phy_vars_ue.UE_State ~= 1
            harq_pid = subframe2harq_pid(frame_parms,frame_tx,subframe_tx);
            
          %%判断是否要发送Msg3
          %%解析RAR，获取PUSCH参数
          
          if phy_vars_ue.ulsch_ue.harq_processes(harq_pid).subframe_scheduling_flag == 1
              generate_ul_signal = 1;
              phy_vars_ue.ulsch_ue.harq_processes(harq_pid).subframe_scheduling_flag = 0;
%               ack_status = get_ack();%% 36.213 table 10.1-1 TODO
              first_rb = phy_vars_ue.ulsch_ue.harq_processes(harq_pid).first_rb;
              nb_rb = phy_vars_ue.ulsch_ue.harq_processes(harq_pid).nb_rb;
              
              msg3_flag = 0;
              if(msg3_flag == 1)
                  %%send msg3 TODO
              else
                  %%从L2获取数据
                  %%仿真时可以采用L1自己产生数据
                  input_buffer_length = phy_vars_ue.ulsch_ue.harq_processes(harq_pid).TBS;
                  ulsch_input_buf = round(2*rand(1,input_buffer_length)/2);%%随机生成input_buffer_length个bit
                  
                  ulsch_encoding(ulsch_input_buf,phy_vars_ue,harq_pid,0,0,0);
                  
                  ulsch_modulation(phy_vars_ue,amp,frame_tx,subframe_tx,phy_vars_ue.ulsch_ue);%%amp时幅度调整系数，可能与定点话有关，TODO
                  
                  %%generate dmrs ,ul has only one tx antenna
                  generate_drs_pusch(phy_vars_ue,amp,sunframe_tx,first_rb,nb_rb,0);
                  
              end
%           elseif cba == 1%%what is cba?
          elseif pucch == 1 && phy_vars_ue.UE_State == 3;%% PUCCH发送条件判断，TODO
              bundling_flag = 0;%%TODO
              payload = 1;
              pucch_format = 0;%%pucch format 1
              tx_pucch(phy_vars_ue,pucch_format,payload);
              
          end
          
          if generate_ul_signal == 1
              
              ulsch_start = frame_parms.samples_per_tti*subframe_tx - phy_vars_ue.N_TA_offset;
              
              if frame_parms.Ncp == 0
                  nsymb = 14;
              else 
                  nsymb = 12;
              end
              
              %%生成SC-FDMA符号
              phy_ofdm_mod();%%TODO
              
              %%偏移7.5KHZ
              %%TODO   
          end     
        end
                  
        %%发送prach
        %%应该由L2触发，仿真时可以由L1自行触发
        %%TODO
        
    end

end

