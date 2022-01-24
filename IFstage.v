module IFstage(clk,rst,should_br,PC_sel,imem_wea,imem_addra,imem_dina,bios_addrb,bios_dout,ALU_result,instruction,instruction_raw,PC_reg_out);    
    parameter RESET_PC       = 32'h0000_0000;
    
    //clk,rst signal
    input clk,rst;
    //PC input
    input should_br;
    //IF stage control signals
    input [1:0] PC_sel;
    input [3:0] imem_wea;
    //connection from other stages for IMEM
    input [13:0] imem_addra;
    input [31:0] imem_dina;
    //connection from other stages for BIOS
    input [11:0] bios_addrb;
    output [31:0] bios_dout;
    //JALR
    input [31:0] ALU_result;
    //output signal
    output [31:0] instruction_raw;
    output [31:0] instruction;
    output [31:0] PC_reg_out;
    
    wire [31:0] PC_4;
    wire [31:0] PC;
    wire [31:0] instruction_raw_bios;
    wire [31:0] instruction_raw_imem;
    wire INST_sel;
    
    assign INST_sel = (PC[31:28] == 4'b0001) ? 1'b0:1'b1;   //PC[31:28] == 4'b0001, read from IMEM otherwise from BIOS

    mux_4input #(.LENGTH(32)) PC_MUX(
      .in1(RESET_PC),
      .in2(PC_reg_out),
      .in3(PC_4),
      .in4(ALU_result),
      .sel(PC_sel),
      .out(PC));
      
    BIOS BIOS1 (
        .clk(clk),
        .bios_addra(PC[13:2]),               //IF stage (read out instruction)
        .bios_addrb(bios_addrb),             //WB stage (write back data)
        .bios_douta(instruction_raw_bios),   //IF stage (read out instruction) 
        .bios_doutb(bios_dout));             //WB stage (write back data)
         
    IMEM IMEM1 (
      .clk(clk),
      .imem_addra(imem_addra),
      .imem_addrb(PC[15:2]),
      .imem_douta(),    //no use
      .imem_doutb(instruction_raw_imem),
      .imem_dina(imem_dina),
      .imem_dinb(),     //no use
      .imem_wea(imem_wea));
    
    mux_2input #(.LENGTH(32)) INST_MUX(
        .in1(instruction_raw_imem),
        .in2(instruction_raw_bios),
        .sel(INST_sel),
        .out(instruction_raw));

    mux_2input #(.LENGTH(32)) FLUSH_MUX(
      .in1(32'd0),
      .in2(instruction_raw),
      .sel(~should_br),
      .out(instruction));
      
    REGISTER_R #(.N(32),.INIT(RESET_PC)) PC_REG(
      .q(PC_reg_out),
      .d(PC),
      .clk(clk),
      .rst(rst));
    
    adder #(.LENGTH(32)) add4 (
      .in1(32'd4),
      .in2(PC_reg_out),
      .out(PC_4));
      
endmodule
