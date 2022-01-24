module IF2EXE(clk, rst, instruction_in, PC_in, PC_rst,A_sel_in, B_sel_in, CSR_sel_in, CSR_WE_in, ALU_sel_in, Reg_WE_in, DMEM_sel_in, LOAD_sel_in, WB_sel_in,
                instruction_out, PC_out, A_sel_out, B_sel_out, CSR_sel_out, CSR_WE_out, ALU_sel_out, Reg_WE_out, DMEM_sel_out, LOAD_sel_out, WB_sel_out);
        
          //inputs
          input clk,rst;
          input [31:0] instruction_in;
          input [31:0] PC_in;
          input [31:0] PC_rst;
          //input:control
          input A_sel_in;
          input B_sel_in;
          input CSR_sel_in;
          input CSR_WE_in;
          input [3:0] ALU_sel_in;
          input Reg_WE_in;
          input [1:0] DMEM_sel_in;
          input [2:0] LOAD_sel_in;
          input [1:0] WB_sel_in;
          //outputs
          output reg [31:0] instruction_out;
          output reg [31:0] PC_out;
          //output:control
          output reg A_sel_out;
          output reg B_sel_out;
          output reg CSR_sel_out;
          output reg CSR_WE_out;
          output reg [3:0] ALU_sel_out;
          output reg Reg_WE_out;
          output reg [1:0] DMEM_sel_out;
          output reg [2:0] LOAD_sel_out;
          output reg [1:0] WB_sel_out;
                
          always @ (posedge clk) begin
                if (rst) begin
                    instruction_out <= 32'd0;
                    PC_out <= PC_rst;
                    A_sel_out <= 1'd0;
                    B_sel_out <= 1'd0;
                    CSR_sel_out <= 1'd0;
                    CSR_WE_out <= 1'd0;
                    ALU_sel_out <= 4'd0;
                    Reg_WE_out <= 1'd0;
                    DMEM_sel_out <= 2'd0;
                    LOAD_sel_out <= 3'd0;
                    WB_sel_out <= 2'd0;
                end
                else begin
                  instruction_out <= instruction_in;
                  PC_out <= PC_in;
                  A_sel_out <= A_sel_in;
                  B_sel_out <= B_sel_in;
                  CSR_sel_out <= CSR_sel_in;
                  CSR_WE_out <= CSR_WE_in;
                  ALU_sel_out <= ALU_sel_in;
                  Reg_WE_out <= Reg_WE_in;
                  DMEM_sel_out <= DMEM_sel_in;
                  LOAD_sel_out <= LOAD_sel_in;
                  WB_sel_out <= WB_sel_in;
                end
            end     
endmodule
