module WBstage(clk,ALU_in,DMEM_data_in,instruction,DMEM_sel,LOAD_sel,WB_sel,WB_data_out);
    //inputs
    input clk;
    input [31:0] ALU_in;
    input [31:0] DMEM_data_in;
    input [31:0] instruction;
    //control signals
    input [1:0] DMEM_sel;
    input [2:0] LOAD_sel;
    input [1:0] WB_sel;
    //outputs
    output [31:0] WB_data_out;
    
    //put this as input
    wire[31:0] iomem_data_in;
    wire[31:0] bios_data_in;
    
    //LOAD unit
    wire [1:0] wanted_byte;
    wire [31:0] RAW_data_in;
    wire [31:0] MEM_data;
    
    //CSR unit
    wire [31:0] CSR_out;
    
    //PC unit
    wire [13:0] PC_4;
    wire [31:0] PC_final;

    assign wanted_byte = ALU_in[1:0];
    assign final_PC = {18'd0,PC_4};

    mux_3input #(.LENGTH(32)) DMEM_MUX(
              .in1(iomem_data_in),
              .in2(DMEM_data_in),
              .in3(bios_data_in),
              .sel(DMEM_sel),
              .out(RAW_data_in));

    LOAD_UNIT LOAD_UNIT1(
              .load_type(LOAD_sel),
              .wanted_byte(wanted_byte),
              .raw_din(RAW_data_in),
              .dout(MEM_data));
    
    mux_4input #(.LENGTH(32)) WB_MUX(
              .in1(CSR_out),
              .in2(PC_final),
              .in3(MEM_data),
              .in4(ALU_in),
              .sel(WB_sel),
              .out(WB_data_out));

endmodule
