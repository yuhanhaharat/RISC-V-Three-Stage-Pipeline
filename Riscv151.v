module Riscv151 #(
  parameter CPU_CLOCK_FREQ = 50_000_000,
  parameter RESET_PC       = 32'h4000_0000,
  parameter BAUD_RATE      = 115200,
  parameter BIOS_MIF_HEX   = "bios151v3.mif"
) (
  input  clk,
  input  rst,
  input  FPGA_SERIAL_RX,
  output FPGA_SERIAL_TX,
  output [31:0] csr
);
      
      wire [1:0] PC_sel;
      
      wire [31:0] instruction_IF;
      wire [13:0] PC_IF;
      wire Reg_WE_IF;
      wire [3:0] ALU_sel_IF;
      wire [1:0] PC_sel_IF;
      wire B_sel_IF;
      wire [1:0] DMEM_sel_IF;
      wire [2:0] LOAD_sel_IF;
      wire [1:0] WB_sel_IF;
      wire [3:0] imem_wea_IF;
      
      wire [31:0] instruction_EXE;
      wire [13:0] PC_EXE;
      wire Reg_WE_EXE;
      wire [3:0] ALU_sel_EXE;
      wire B_sel_EXE;
      wire [1:0] DMEM_sel_EXE;
      wire [2:0] LOAD_sel_EXE;
      wire [1:0] WB_sel_EXE;
      wire [3:0] imem_wea_EXE;
      wire [31:0] ALU_result_EXE;
      wire [31:0] DMEM_data_EXE;
      
      wire [31:0] instruction_MWB;
      wire [13:0] PC_MWB;
      wire Reg_WE_MWB;
      wire [1:0] DMEM_sel_MWB;
      wire [2:0] LOAD_sel_MWB;
      wire [1:0] WB_sel_MWB;
      wire [3:0] imem_wea_MWB;
      wire [31:0] ALU_result_MWB;
      wire [31:0] Reg_DataB_MWB;
      wire [31:0] WB_data_out_MWB;
      
      IFstage IFstage1(
              .clk(clk),
              .rst(rst),
              .PC_rst(14'd0),
              .PC_sel(PC_sel),
              .imem_wea(imem_wea_MWB),
              .imem_addra(ALU_result_MWB[13:0]),
              .imem_dina(Reg_DataB_MWB),
              .instruction(instruction_IF),
              .PC_reg_out(PC_IF));

      controlunit controlunit1(
              .rst(rst),
              .instruction(instruction_IF),
              .Reg_WE(Reg_WE_IF),
              .ALU_sel(ALU_sel_IF),
              .PC_sel(PC_sel),
              .B_sel(B_sel_IF),
              .DMEM_sel(DMEM_sel_IF),
              .LOAD_sel(LOAD_sel_IF),
              .WB_sel(WB_sel_IF),
              .imem_wea(imem_wea_IF));

      EXstage EXstage1(
              .clk(clk),
              .instruction_EXE(instruction_EXE),
              .instruction_MWB(instruction_MWB),
              .DataDin(WB_data_out_MWB),
              .Reg_WE(Reg_WE_MWB),
              .ALU_sel(ALU_sel_EXE),
              .B_sel(B_sel_EXE),
              .ALU_result(ALU_result_EXE),
              .DMEM_data_out(DMEM_data_EXE));
              
      WBstage WBstage1(
              .clk(clk),
              .DMEM_data_in(DMEM_data_EXE),
              .ALU_in(ALU_result_MWB),
              .instruction(instruction_MWB),
              .DMEM_sel(DMEM_sel_MWB),
              .LOAD_sel(LOAD_sel_MWB),
              .WB_sel(WB_sel_MWB),
              .WB_data_out(WB_data_out_MWB));
              
      IF2EXE IF2EXE1(
              .clk(clk), 
              .rst(rst), 
              .instruction_in(instruction_IF), 
              .PC_in(PC_IF), 
              .B_sel_in(B_sel_IF), 
              .ALU_sel_in(ALU_sel_IF), 
              .Reg_WE_in(Reg_WE_IF), 
              .DMEM_sel_in(DMEM_sel_IF), 
              .LOAD_sel_in(LOAD_sel_IF), 
              .WB_sel_in(WB_sel_IF),
              .instruction_out(instruction_EXE), 
              .PC_out(PC_EXE), 
              .B_sel_out(B_sel_EXE), 
              .ALU_sel_out(ALU_sel_EXE), 
              .Reg_WE_out(Reg_WE_EXE), 
              .DMEM_sel_out(DMEM_sel_EXE), 
              .LOAD_sel_out(LOAD_sel_EXE), 
              .WB_sel_out(WB_sel_EXE));
      
      EXE2MWB EXE2MWB1(
              .clk(clk),
              .rst(rst),
              .instruction_in(instruction_EXE), 
              .ALU_result_in(ALU_result_EXE), 
              .PC_in(PC_EXE), 
              .Reg_WE_in(Reg_WE_EXE), 
              .DMEM_sel_in(DMEM_sel_EXE), 
              .LOAD_sel_in(LOAD_sel_EXE), 
              .WB_sel_in(WB_sel_EXE),
              .instruction_out(instruction_MWB), 
              .ALU_result_out(ALU_result_MWB), 
              .PC_out(PC_MWB), 
              .Reg_WE_out(Reg_WE_MWB), 
              .DMEM_sel_out(DMEM_sel_MWB), 
              .LOAD_sel_out(LOAD_sel_MWB), 
              .WB_sel_out(WB_sel_MWB));
      
      wire [31:0] instruction_MWB_q;
      REGISTER_R #(.N(32)) INST_REG(
                    .q(instruction_MWB_q),
                    .d(instruction_MWB),
                    .clk(clk),
                    .rst(rst));
  
endmodule
