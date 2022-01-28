`include "Opcode.vh"

module hazard_unit(instruction_EXE,instruction_MWB,FWD_A_sel_EXE,FWD_B_sel_EXE);
        input [31:0] instruction_EXE;
        input [31:0] instruction_MWB;
        output [2:0] FWD_A_sel_EXE,FWD_B_sel_EXE;
        
        wire [4:0] AddrA_EXE,AddrB_EXE,AddrD_MWB;
        wire [4:0] opcode5_MWB;
        wire [4:0] opcode5_EXE;
        
        assign AddrA_EXE = instruction_EXE[19:15];
        assign AddrB_EXE = instruction_EXE[24:20];
        assign AddrD_MWB = instruction_MWB[11:7];
        assign opcode5_MWB = instruction_MWB[6:2];
        assign opcode5_EXE = instruction_EXE[6:2];
        assign opcode7_EXE = instruction_EXE[6:0];
        
        wire check_CSR;
        assign check_CSR = (opcode5_EXE == `OPC_CSR_5) && (instruction_EXE[14] == 1'b1);
        
        
        wire is_r1_zero;
        wire is_r2_zero;
        
        assign is_r1_zero = (AddrA_EXE == 0 && AddrD_MWB == 0) ? 1'b1 : 1'b0;
        assign is_r2_zero = (AddrB_EXE == 0 && AddrD_MWB == 0) ? 1'b1 : 1'b0;

        wire is_r1_valid;
        wire is_r2_valid;
        
        assign is_r1_valid = (opcode5_EXE == `OPC_LUI_5 || opcode5_EXE == `OPC_AUIPC_5 || opcode5_EXE == `OPC_JAL_5 || check_CSR) ? 1'b0 : 1'b1;
        assign is_r2_valid = (opcode5_EXE == `OPC_LUI_5 || opcode5_EXE == `OPC_AUIPC_5 || opcode5_EXE == `OPC_CSR_5 || opcode5_EXE == `OPC_ARI_ITYPE_5 || opcode5_EXE == `OPC_JALR_5) ? 1'b0 : 1'b1;
        
        wire is_r1_equal;
        wire is_r2_equal;
        assign is_r1_equal = (AddrA_EXE == AddrD_MWB) && ~is_r1_zero;
        assign is_r2_equal = (AddrB_EXE == AddrD_MWB) && ~is_r2_zero;

        wire is_r1_hazard;
        wire is_r2_hazard;
        assign is_r1_hazard = is_r1_valid && is_r1_equal;
        assign is_r2_hazard = is_r2_valid && is_r2_equal;
        
        assign FWD_A_sel_EXE = (is_r1_hazard && (opcode5_MWB == `OPC_JALR_5)) ? 3'd4 :
                               (is_r1_hazard && (opcode5_MWB == `OPC_LUI_5))  ? 3'd3 :
                               (is_r1_hazard && (opcode5_MWB == `OPC_ARI_ITYPE_5 || opcode5_MWB == `OPC_ARI_RTYPE_5 || opcode5_MWB == `OPC_JAL_5 || opcode5_MWB == `OPC_AUIPC_5)) ? 3'd1 : 3'd0;
                               
        assign FWD_B_sel_EXE = (is_r1_hazard && (opcode5_MWB == `OPC_JALR_5)) ? 3'd4 :
                               (is_r2_hazard && (opcode5_MWB == `OPC_LUI_5)) ? 3'd3 :
                               (is_r2_hazard && (opcode5_MWB == `OPC_ARI_ITYPE_5 || opcode5_MWB == `OPC_ARI_RTYPE_5 || opcode5_MWB == `OPC_JAL_5 || opcode5_MWB == `OPC_AUIPC_5)) ? 3'd1 : 3'd0;
        
        
        //assign FWD_A_sel_EXE = ((AddrA_EXE == AddrD_MWB) && (opcode5 == `OPC_LOAD_5 || opcode5 == `OPC_JAL_5)) ? 2'd2 :    //ALU-ALU Hazard on DataA, no need special handle for 2cycle ALU, also handle ALU->SW
        //                       (AddrA_EXE == AddrD_MWB) ? 2'd1 : 2'd0;    //LW-ALU Hazard
        //assign FWD_B_sel_EXE = ((AddrB_EXE == AddrD_MWB) && (opcode5 == `OPC_LOAD_5 || opcode5 == `OPC_JAL_5)) ? 2'd2 :    //ALU-ALU Hazard on DataA, no need special handle for 2cycle ALU, also handle ALU->SW
        //                       (AddrB_EXE == AddrD_MWB) ? 2'd1 : 2'd0;    //LW-ALU Hazard
        
                              
endmodule
