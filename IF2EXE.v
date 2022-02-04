module IF2EXE(clk, rst, instruction_in, PC_in, PC_rst,instruction_out, PC_out);
        
          //inputs
          input clk,rst;
          input [31:0] instruction_in;
          input [31:0] PC_in;
          input [31:0] PC_rst;
          //outputs
          output reg [31:0] instruction_out;
          output reg [31:0] PC_out;
                
          always @ (posedge clk) begin
                if (rst) begin
                    instruction_out <= 32'd0;
                    PC_out <= PC_rst;
                end
                else begin
                  instruction_out <= instruction_in;
                  PC_out <= PC_in;
                end
            end     
endmodule
