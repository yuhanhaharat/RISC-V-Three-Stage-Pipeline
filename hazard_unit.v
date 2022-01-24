`include "Opcode.vh"

module hazard_unit(instruction_EXE,instruction_MWB,FWD_A_sel_EXE,FWD_B_sel_EXE);
    input [31:0] instruction_EXE;
    input [31:0] instruction_MWB;
    output [1:0] FWD_A_sel_EXE,FWD_B_sel_EXE;
    
    wire [4:0] AddrA_EXE,AddrB_EXE,AddrD_MWB;
    wire [4:0] opcode5;
    
    assign AddrA_EXE = instruction_EXE[19:15];
    assign AddrB_EXE = instruction_EXE[24:20];
    assign AddrD_MWB = instruction_MWB[11:7];
    assign opcode5 = instruction_MWB[6:2];
    
    assign FWD_A_sel_EXE = ((AddrA_EXE == AddrD_MWB) && (opcode5 == `OPC_LOAD_5 || opcode5 == `OPC_JAL_5)) ? 2'd2 :    //ALU-ALU Hazard on DataA, no need special handle for 2cycle ALU, also handle ALU->SW
                           (AddrA_EXE == AddrD_MWB) ? 2'd1 : 2'd0;    //LW-ALU Hazard
    assign FWD_B_sel_EXE = ((AddrB_EXE == AddrD_MWB) && (opcode5 == `OPC_LOAD_5 || opcode5 == `OPC_JAL_5)) ? 2'd2 :    //ALU-ALU Hazard on DataA, no need special handle for 2cycle ALU, also handle ALU->SW
                           (AddrB_EXE == AddrD_MWB) ? 2'd1 : 2'd0;    //LW-ALU Hazard
    
endmodule
