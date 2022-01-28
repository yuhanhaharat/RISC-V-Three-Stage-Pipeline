`include "Opcode.vh"

module controlunit(rst,instruction,should_br,PC,Reg_WE,ALU_sel,PC_sel,A_sel,B_sel,CSR_sel,CSR_WE,DMEM_sel,LOAD_sel,WB_sel);
    input rst;
    input [31:0] instruction;
    input should_br;
    input [31:0] PC;
    output reg Reg_WE;
    output reg [3:0] ALU_sel;
    output reg [2:0] PC_sel;
    output reg A_sel;
    output reg B_sel;
    output reg CSR_sel;
    output reg CSR_WE;
    output [1:0] DMEM_sel;
    output reg [2:0] LOAD_sel;
    output reg [1:0] WB_sel;
   
    wire [6:0] opcode7 = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire RTYPE_bit30 = instruction[30];
    wire ITYPE_bit30 = (instruction[14:12] == `FNC_SRL_SRA) ? instruction[30] : 1'b0;
    
    //in1:DMEM;in2:BIOS (for LOAD instruction)
    assign DMEM_sel = (PC[31:28] == 4'b0011 || PC[31:28] == 4'b0001) ? 2'd1 :   //DMEM
                      (PC[31:28] == 4'b0100) ? 2'd2 : 2'd0;                     //BIOS
    
    always @(*) begin
    if(~rst)begin
            case (opcode7)
                `OPC_ARI_RTYPE: begin
                    Reg_WE = 1'b1;
                    ALU_sel = {RTYPE_bit30,funct3};
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b1;
                    B_sel = 1'b1;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd3;
                end
                `OPC_ARI_ITYPE: begin
                    Reg_WE = 1'b1;
                    ALU_sel = {ITYPE_bit30,funct3};
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b1;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd3;
                end
                `OPC_LOAD: begin
                    Reg_WE = 1'b1;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b1;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = funct3;
                    WB_sel = 2'd2;
                end
                `OPC_CSR:begin
                    Reg_WE = 1'b0;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b1;
                    B_sel = 1'b0;
                    CSR_sel = ~funct3[2];
                    CSR_WE = 1'b1;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'b0;
                end
                `OPC_STORE:begin
                    Reg_WE = 1'b0;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b1;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd0;
                end
                `OPC_LUI:begin
                    Reg_WE = 1'b1;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b0;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd0;
                end
                `OPC_AUIPC:begin
                    Reg_WE = 1'b1;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b0;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd3;
                end
                `OPC_JALR:begin
                    Reg_WE = 1'b1;
                    ALU_sel = 4'b0;
                    PC_sel = 3'd3;
                    A_sel = 1'b1;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd1;
                end
                `OPC_JAL:begin
                    Reg_WE = 1'b1;
                    ALU_sel = 4'b0;
                    PC_sel = 3'd4;
                    A_sel = 1'b0;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd1;
                end
                `OPC_BRANCH:begin
                    Reg_WE = 1'b0;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b0;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd0;
                end
                `OPC_CSR:begin
                    Reg_WE = 1'b0;
                    ALU_sel = 4'b0;
                    PC_sel = (should_br == 1'b1) ? 3'd3 : 3'd2;
                    A_sel = 1'b0;
                    B_sel = 1'b0;
                    CSR_sel = ~funct3[2];
                    CSR_WE = 1'b1;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'd0;
                end
                default:begin
                    Reg_WE = 1'b0;
                    ALU_sel = 4'b0;
                    PC_sel = 3'd0;
                    A_sel = 1'b0;
                    B_sel = 1'b0;
                    CSR_sel = 1'b0;
                    CSR_WE = 1'b0;
                    LOAD_sel = 3'b0;
                    WB_sel = 2'b0;
                end
            endcase
    end else begin
            Reg_WE = 1'b0;
            ALU_sel = 4'b0;
            PC_sel = 3'd0;
            A_sel = 1'b0;
            B_sel = 1'b0;
            CSR_sel = 1'b0;
            CSR_WE = 1'b0;
            LOAD_sel = 3'b0;
            WB_sel = 2'b0;
    end
    end
endmodule
