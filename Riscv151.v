module Riscv151 #(
  parameter CPU_CLOCK_FREQ = 50_000_000,
  parameter RESET_PC       = 32'h4000_0000, //BIOS:32'h4000_0000;INST:32'h1000_0000;
  parameter BAUD_RATE      = 115200,
  parameter BIOS_MIF_HEX   = "bios151v3.mif"
) (
  input  clk,
  input  rst,
  input  FPGA_SERIAL_RX,
  output FPGA_SERIAL_TX,
  output [31:0] csr
);
      
      wire [2:0] PC_sel;
      
      wire [31:0] instruction_IF;
      wire [31:0] instruction_raw_IF;
      wire [31:0] PC_IF;
      wire [31:0] bios_dout;
      
      wire [31:0] instruction_EXE;
      wire [31:0] PC_EXE;
      wire Reg_WE_EXE;
      wire [3:0] ALU_sel_EXE;
      wire A_sel_EXE;
      wire B_sel_EXE;
      wire CSR_sel_EXE;
      wire CSR_WE_EXE;
      wire [1:0] DMEM_sel_EXE;
      wire [2:0] LOAD_sel_EXE;
      wire [1:0] WB_sel_EXE;
      wire [3:0] imem_wea_EXE;
      wire [31:0] imem_dina_EXE;
      wire [31:0] IMME_result_EXE;
      wire [31:0] ALU_result_EXE;
      wire [31:0] DMEM_data_EXE;
      wire [31:0] uart_data_load_EXE;
      wire should_br;
      
      wire [31:0] instruction_MWB;
      wire [31:0] PC_MWB;
      wire Reg_WE_MWB;
      wire [1:0] DMEM_sel_MWB;
      wire [2:0] LOAD_sel_MWB;
      wire [1:0] WB_sel_MWB;
      wire [31:0] IMME_result_MWB;
      wire [31:0] PC_4_result_MWB;
      wire [31:0] ALU_result_MWB;
      wire [31:0] Reg_DataB_MWB;
      wire [31:0] WB_data_out_MWB;
      wire [31:0] uart_data_load_MWB;
      
      wire [2:0] FWD_A_sel_EXE;
      wire [2:0] FWD_B_sel_EXE;
      
      hazard_unit hazard_unit1(
              .instruction_EXE(instruction_EXE),
              .instruction_MWB(instruction_MWB),
              .FWD_A_sel_EXE(FWD_A_sel_EXE),
              .FWD_B_sel_EXE(FWD_B_sel_EXE));

      IFstage #(.RESET_PC(RESET_PC),.MIF_HEX(BIOS_MIF_HEX)) IFstage1(
              .clk(clk),
              .rst(rst),
              .should_br(should_br),
              .PC_sel(PC_sel),
              .imem_wea(imem_wea_EXE),
              .imem_addra(ALU_result_EXE[15:2]),
              .imem_dina(imem_dina_EXE),
              .bios_addrb(ALU_result_EXE[13:2]),
              .bios_dout(bios_dout),
              .ALU_result(ALU_result_EXE),
              .instruction(instruction_IF),
              .instruction_raw(instruction_raw_IF),
              .PC_reg_out(PC_IF),
              .instruction_EXE(instruction_EXE),
              .PC_EXE(PC_EXE));
        
      controlunit controlunit1(
              .rst(rst),
              .instruction(instruction_EXE),
              .should_br(should_br),
              .PC(PC_IF),
              .ALU_result(ALU_result_EXE),
              .Reg_WE(Reg_WE_EXE),
              .ALU_sel(ALU_sel_EXE),
              .PC_sel(PC_sel),
              .A_sel(A_sel_EXE),
              .B_sel(B_sel_EXE),
              .CSR_sel(CSR_sel_EXE),
              .CSR_WE(CSR_WE_EXE),
              .DMEM_sel(DMEM_sel_EXE),
              .LOAD_sel(LOAD_sel_EXE),
              .WB_sel(WB_sel_EXE));

      EXstage #(.CLOCK_FREQ(CPU_CLOCK_FREQ),.BAUD_RATE(BAUD_RATE)) EXstage1(
              .clk(clk),
              .rst(rst),
              .PC(PC_EXE),
              .instruction_EXE(instruction_EXE),
              .instruction_MWB(instruction_MWB),
              .DataDin(WB_data_out_MWB),
              .ALU_result_MWB(ALU_result_MWB),
              .IMME_out_MWB(IMME_result_MWB),
              .PC_4_MWB(PC_4_result_MWB),
              .Reg_WE_IF(Reg_WE_MWB),
              .ALU_sel_IF(ALU_sel_EXE),
              .WB_data(WB_data_out_MWB),
              .A_sel_IF(A_sel_EXE),
              .B_sel_IF(B_sel_EXE),
              .CSR_sel_IF(CSR_sel_EXE),
              .CSR_WE_IF(CSR_WE_EXE),
              .FWD_A_sel_IF(FWD_A_sel_EXE),
              .FWD_B_sel_IF(FWD_B_sel_EXE),
              .ALU_result(ALU_result_EXE),
              .IMME_out(IMME_result_EXE),
              .DMEM_data_out(DMEM_data_EXE),
              .should_br(should_br),
              .mem_data(imem_dina_EXE),     //pass back to imem
              .imem_wea(imem_wea_EXE),      //pass back to imem
              .CSR_dout(csr),               //csr register
              .serial_in(FPGA_SERIAL_RX),
              .serial_out(FPGA_SERIAL_TX),
              .uart_data_load(uart_data_load_EXE));              
              
      WBstage WBstage1(
              .clk(clk),
              .DMEM_data_in(DMEM_data_EXE),
              .bios_data_in(bios_dout),
              .iomem_data_in(uart_data_load_MWB),
              .IMME_in(IMME_result_MWB),
              .ALU_in(ALU_result_MWB),
              .PC(PC_MWB),
              .PC_4_out(PC_4_result_MWB),
              .instruction(instruction_MWB),
              .DMEM_sel_EXE(DMEM_sel_MWB),
              .LOAD_sel_EXE(LOAD_sel_MWB),
              .WB_sel_EXE(WB_sel_MWB),
              .WB_data_out(WB_data_out_MWB));
              
      IF2EXE IF2EXE1(
              .clk(clk), 
              .rst(rst), 
              .instruction_in(instruction_IF), 
              .PC_in(PC_IF),
              .PC_rst(RESET_PC),
              .instruction_out(instruction_EXE), 
              .PC_out(PC_EXE));
      
      EXE2MWB EXE2MWB1(
              .clk(clk),
              .rst(rst),
              .instruction_in(instruction_EXE),
              .IMME_result_in(IMME_result_EXE), 
              .ALU_result_in(ALU_result_EXE),
              .iomem_data_in(uart_data_load_EXE), 
              .PC_in(PC_EXE),
              .PC_rst(RESET_PC),
              .Reg_WE_in(Reg_WE_EXE), 
              .DMEM_sel_in(DMEM_sel_EXE), 
              .LOAD_sel_in(LOAD_sel_EXE), 
              .WB_sel_in(WB_sel_EXE),
              .instruction_out(instruction_MWB),
              .IMME_result_out(IMME_result_MWB),  
              .ALU_result_out(ALU_result_MWB),
              .iomem_data_out(uart_data_load_MWB), 
              .PC_out(PC_MWB), 
              .Reg_WE_out(Reg_WE_MWB), 
              .DMEM_sel_out(DMEM_sel_MWB), 
              .LOAD_sel_out(LOAD_sel_MWB), 
              .WB_sel_out(WB_sel_MWB));
        
endmodule
