`include "Opcode.vh"

module EXstage(clk,rst,PC,instruction_EXE,instruction_MWB,DataDin,ALU_result_MWB,IMME_out_MWB,PC_4_MWB,
                Reg_WE_IF,ALU_sel_IF,A_sel_IF,B_sel_IF,CSR_sel_IF,CSR_WE_IF,FWD_A_sel_IF,FWD_B_sel_IF,WB_data,ALU_result,
                IMME_out,DMEM_data_out,should_br,mem_data,imem_wea,CSR_dout);
    
    //clk,rst signal
    input clk,rst;
    //instruction input
    input [31:0] PC;
    input [31:0] instruction_EXE;
    input [31:0] instruction_MWB;
    input [31:0] DataDin;
    input [31:0] ALU_result_MWB;
    input [31:0] IMME_out_MWB;
    input [31:0] PC_4_MWB;
    //control signals
    input Reg_WE_IF;
    input [3:0] ALU_sel_IF;
    input B_sel_IF;
    input A_sel_IF;
    input CSR_sel_IF;
    input CSR_WE_IF;
    input [2:0] FWD_A_sel_IF;
    input [2:0] FWD_B_sel_IF;
    //DMEM fwd
    input [31:0] WB_data;
    //outputs
    output [31:0] ALU_result;
    output [31:0] IMME_out;           //Data out from IMMEout unit
    output [31:0] DMEM_data_out;    //output from dmem
    output should_br;
    //outputs for imem
    output [31:0] mem_data;         //need output mem_data since instruction memory will need this
    output [3:0] imem_wea;          //need output imem_wea since instruction memory will need this
    //CSR data
    output [31:0] CSR_dout;
    
    wire Reg_WE;
    wire [3:0] ALU_sel;
    wire B_sel;
    wire A_sel;
    wire CSR_sel;
    wire CSR_WE;
    wire [2:0] FWD_A_sel;
    wire [2:0] FWD_B_sel;
    assign Reg_WE = (instruction_EXE == 0) ? 1'd0 : Reg_WE_IF;
    assign ALU_sel = (instruction_EXE == 0) ? 1'd0 : ALU_sel_IF;
    assign B_sel = (instruction_EXE == 0) ? 1'd0 : B_sel_IF;
    assign A_sel = (instruction_EXE == 0) ? 1'd0 : A_sel_IF;
    assign CSR_sel = (instruction_EXE == 0) ? 1'd0 : CSR_sel_IF;
    assign CSR_WE = (instruction_EXE == 0) ? 1'd0 : CSR_WE_IF;
    assign FWD_A_sel = (instruction_EXE == 0) ? 3'd0 : FWD_A_sel_IF;
    assign FWD_B_sel = (instruction_EXE == 0) ? 3'd0 : FWD_B_sel_IF;

    wire [31:0] DataAout,DataBout;  //From Reg File
    wire [31:0] DataAin,DataBin;    //Data into ALU 
    wire [31:0] DataAout_final,DataBout_final;  //DataA and DataB after forwarding
    //Reg File DataA and DataB
    wire [31:0] Reg_DataA;
    wire [31:0] Reg_DataB;
    //DMEM part:bios,dmem,iomem
    wire [11:0] bios_addra;
    wire [31:0] bios_douta; //put this as output
    wire [3:0] bios_wea;
    wire [11:0] iomem_addra;
    wire [31:0] iomem_dout; //put this as output
    wire [3:0] iomem_wea;
    wire [13:0] dmem_addra;
    wire [3:0] dmem_wea;
    wire [31:0] CSR_din;

    assign Reg_DataB = DataBout;    //same signal but name it differently for better clarity
    assign Reg_DataA = DataAout;    //same signal but name it differently for better clarity   
    assign dmem_addra = ALU_result[15:2];

    RegFile RegFile1(
        .clk(clk),
        .Reg_WE(Reg_WE),
        .DataA_new(DataAout),
        .DataB_new(DataBout),
        .DataD(DataDin),
        .AddrA(instruction_EXE[19:15]),
        .AddrB(instruction_EXE[24:20]),
        .AddrD(instruction_MWB[11:7]));
        
    IMME_GEN IMME_GNE1(
            .instruction(instruction_EXE),
            .IMME_out(IMME_out));
            
    mux_2input #(.LENGTH(32)) A_MUX(
            .in1(PC),
            .in2(DataAout_final),
            .sel(A_sel),
            .out(DataAin));
                
    mux_2input #(.LENGTH(32)) B_MUX(
            .in1(IMME_out),
            .in2(DataBout_final),
            .sel(B_sel),
            .out(DataBin));

    ALU ALU1(
        .DataA(DataAin),
        .DataB(DataBin),
        .ALUsel(ALU_sel),
        .instruction(instruction_EXE),
        .result(ALU_result));
        
    BRANCH_UNIT BRANCH_UNIT1(
        .rst(rst),
        .DataA(DataAout_final),
        .DataB(DataBout_final),
        .instruction(instruction_EXE),
        .should_br(should_br));

    mux_2input #(.LENGTH(32)) CSR_MUX(
            .in1(IMME_out),
            .in2(DataAout_final),
            .sel(CSR_sel),
            .out(CSR_din));
    
    CSR_RegFile CSR_RegFile1(
            .clk(clk),
            .CSR_WE(CSR_WE),
            .din(CSR_din),
            .Addr(12'h51E),
            .dout(CSR_dout));
    
    MEM_WRITE_CONTROL MEM_WRITE_CONTROL1(
            .instruction(instruction_EXE),
            .ALU_result(ALU_result),
            .PC(PC),
            .din_raw(Reg_DataB),
            .dmem_wea(dmem_wea),
            .imem_wea(imem_wea),
            .dout(mem_data));        

    DMEM DMEM1(
            .clk(clk),
            .dmem_addra(dmem_addra),
            .dmem_douta(DMEM_data_out),
            .dmem_dina(mem_data),
            .dmem_wea(dmem_wea));
            
    mux_5input #(.LENGTH(32)) A_FWD_MUX(
            .in1(DataAout),
            .in2(ALU_result_MWB),
            .in3(WB_data),
            .in4(IMME_out_MWB),
            .in5(PC_4_MWB),
            .sel(FWD_A_sel),
            .out(DataAout_final));
            
    mux_5input #(.LENGTH(32)) B_FWD_MUX(
            .in1(DataBout),
            .in2(ALU_result_MWB),
            .in3(WB_data),
            .in4(IMME_out_MWB),
            .in5(PC_4_MWB),
            .sel(FWD_B_sel),
            .out(DataBout_final));
            
endmodule
