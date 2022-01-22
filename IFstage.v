module IFstage(clk,rst,should_br,PC_rst,PC_sel,imem_wea,imem_addra,imem_dina,ALU_result,instruction,instruction_raw,PC_reg_out);    
    //clk,rst signal
    input clk,rst;
    //PC input
    input should_br;
    input [31:0] PC_rst;
    //IF stage control signals
    input [1:0] PC_sel;
    input [3:0] imem_wea;
    //connection from other stages
    input [13:0] imem_addra;
    input [31:0] imem_dina;
    //JALR
    input [31:0] ALU_result;
    //output signal
    output [31:0] instruction_raw;
    output [31:0] instruction;
    output [31:0] PC_reg_out;
    
    wire [31:0] PC_4;
    wire [31:0] PC;

    mux_4input #(.LENGTH(32)) PC_MUX(
      .in1(PC_rst),
      .in2(PC_reg_out),
      .in3(PC_4),
      .in4(ALU_result),
      .sel(PC_sel),
      .out(PC));
    
    IMEM IMEM1 (
      .clk(clk),
      .imem_addra(imem_addra),
      .imem_addrb(PC[15:2]),
      .imem_douta(),    //no use
      .imem_doutb(instruction_raw),
      .imem_dina(imem_dina),
      .imem_dinb(),     //no use
      .imem_wea(imem_wea));
      
    mux_2input #(.LENGTH(32)) FLUSH_MUX(
      .in1(32'd0),
      .in2(instruction_raw),
      .sel(~should_br),
      .out(instruction));
      
    REGISTER_R #(.N(32)) PC_REG(
      .q(PC_reg_out),
      .d(PC),
      .clk(clk),
      .rst(rst));
    
    adder #(.LENGTH(32)) add4 (
      .in1(32'd4),
      .in2(PC_reg_out),
      .out(PC_4));
      
endmodule
