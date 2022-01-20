module IFstage(clk,rst,PC_rst,PC_sel,imem_wea,imem_addra,imem_dina,instruction,PC_reg_out);    
    //clk,rst signal
    input clk,rst;
    //PC input
    input [13:0] PC_rst;
    //IF stage control signals
    input [1:0] PC_sel;
    input [3:0] imem_wea;
    //connection from other stages
    input [13:0] imem_addra;
    input [31:0] imem_dina;
    //output signal
    output [31:0] instruction;
    output [13:0] PC_reg_out;
    
    wire [13:0] PC_4;
    wire [13:0] PC;

    mux_3input #(.LENGTH(14)) PC_MUX(
      .in1(PC_rst),
      .in2(PC_reg_out),
      .in3(PC_4),
      .sel(PC_sel),
      .out(PC));
    
    IMEM IMEM1 (
      .clk(clk),
      .imem_addra(imem_addra),
      .imem_addrb(PC),
      .imem_douta(),    //no use
      .imem_doutb(instruction),
      .imem_dina(imem_dina),
      .imem_dinb(),     //no use
      .imem_wea(imem_wea));
      
    REGISTER_R #(.N(14)) PC_REG(
      .q(PC_reg_out),
      .d(PC),
      .clk(clk),
      .rst(rst));
    
    adder #(.LENGTH(14)) add4 (
      .in1(14'd1),
      .in2(PC_reg_out),
      .out(PC_4));
      
endmodule
