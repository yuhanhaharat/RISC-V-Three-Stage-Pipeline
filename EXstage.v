module EXstage(clk,PC,instruction_EXE,instruction_MWB,DataDin,Reg_WE,ALU_sel,A_sel,B_sel,CSR_sel,CSR_WE,ALU_result,IMME_out,DMEM_data_out,mem_data,imem_wea);
    //clk,rst signal
    input clk;
    //instruction input
    input [31:0] PC;
    input [31:0] instruction_EXE;
    input [31:0] instruction_MWB;
    input [31:0] DataDin;
    //control signals
    input Reg_WE;
    input [3:0] ALU_sel;
    input B_sel;
    input A_sel;
    input CSR_sel;
    input CSR_WE;
    //outputs
    output [31:0] ALU_result;
    output [31:0] IMME_out;           //Data out from IMMEout unit
    output [31:0] DMEM_data_out;    //output from dmem
    //outputs for imem
    output [31:0] mem_data;         //need output mem_data since instruction memory will need this
    output [3:0] imem_wea;          //need output imem_wea since instruction memory will need this
    
    wire [31:0] DataAout,DataBout;  //From Reg File
    wire [31:0] DataAin,DataBin;    //Data into ALU 
    //Reg File DataA and DataB
    wire [31:0] Reg_DataA;
    wire [31:0] Reg_DataB;
    //CSR data
    wire [31:0] CSR_dout;
    //DMEM part:bios,dmem,iomem
    wire [11:0] bios_addra;
    wire [31:0] bios_douta; //put this as output
    wire [3:0] bios_wea;
    wire [11:0] iomem_addra;
    wire [31:0] iomem_dout; //put this as output
    wire [3:0] iomem_wea;
    wire [13:0] dmem_addra;
    wire [3:0] dmem_wea;

    assign Reg_DataB = DataBout;    //same signal but name it differently for better clarity
    assign Reg_DataA = DataAout;    //same signal but name it differently for better clarity   
    assign dmem_addra = ALU_result[15:2];
    
    RegFile RegFile1(
        .clk(clk),
        .Reg_WE(Reg_WE),
        .DataA(DataAout),
        .DataB(DataBout),
        .DataD(DataDin),
        .AddrA(instruction_EXE[19:15]),
        .AddrB(instruction_EXE[24:20]),
        .AddrD(instruction_MWB[11:7]));
        
    IMME_GEN IMME_GNE1(
            .instruction(instruction_EXE),
            .IMME_out(IMME_out));
            
    mux_2input #(.LENGTH(32)) A_MUX(
            .in1(PC),
            .in2(DataAout),
            .sel(A_sel),
            .out(DataAin));
                
    mux_2input #(.LENGTH(32)) B_MUX(
            .in1(IMME_out),
            .in2(DataBout),
            .sel(B_sel),
            .out(DataBin));

    ALU ALU1(
        .DataA(DataAin),
        .DataB(DataBin),
        .ALUsel(ALU_sel),
        .result(ALU_result));
        
    mux_2input #(.LENGTH(32)) CSR_MUX(
            .in1(IMME_out),
            .in2(DataAout),
            .sel(CSR_sel),
            .out(CSR_dout));
    
    CSR_RegFile CSR_RegFile1(
            .clk(clk),
            .CSR_WE(CSR_WE),
            .din(CSR_dout),
            .Addr(12'h51E));
    
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

endmodule
