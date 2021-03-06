module EXE2MWB(clk,rst,instruction_in, ALU_result_in, IMME_result_in, PC_in, PC_rst, iomem_data_in, Reg_WE_in, DMEM_sel_in, LOAD_sel_in, WB_sel_in,
              instruction_out, ALU_result_out, IMME_result_out, PC_out, iomem_data_out, Reg_WE_out, DMEM_sel_out, LOAD_sel_out, WB_sel_out);
      
      //inputs
      input clk,rst;
      input [31:0] instruction_in;
      input [31:0] IMME_result_in;
      input [31:0] ALU_result_in;
      input [31:0] PC_in;
      input [31:0] PC_rst;
      input [31:0] iomem_data_in;
      //input:control
      input Reg_WE_in;
      input [1:0] DMEM_sel_in;
      input [2:0] LOAD_sel_in;
      input [1:0] WB_sel_in;
      //inputs
      output reg [31:0] instruction_out;
      output reg [31:0] IMME_result_out;
      output reg [31:0] ALU_result_out;
      output reg [31:0] PC_out;
      output reg [31:0] iomem_data_out;
      //output:control
      output reg Reg_WE_out;
      output reg [1:0] DMEM_sel_out;
      output reg [2:0] LOAD_sel_out;
      output reg [1:0] WB_sel_out;
      
      always @ (posedge clk) begin
          if (rst) begin
              instruction_out <= 32'd0;
              IMME_result_out <= 32'd0;
              ALU_result_out <= 32'd0;
              iomem_data_out <= 32'd0;
              PC_out <= PC_rst;
              Reg_WE_out <= 1'd0;
              DMEM_sel_out <= 2'd0;
              LOAD_sel_out <= 3'd0;
              WB_sel_out <= 2'd0;
          end
          else begin
            instruction_out <= instruction_in;
            IMME_result_out <= IMME_result_in;
            ALU_result_out <= ALU_result_in;
            iomem_data_out <= iomem_data_in;
            PC_out <= PC_in;
            Reg_WE_out <= Reg_WE_in;
            DMEM_sel_out <= DMEM_sel_in;
            LOAD_sel_out <= LOAD_sel_in;
            WB_sel_out <= WB_sel_in;
          end
      end     
endmodule
