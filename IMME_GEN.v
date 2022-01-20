`include "Opcode.vh"

module IMME_GEN(instruction,IMME_out);
    input [31:0] instruction;
    output reg [31:0] IMME_out;
    
    wire [4:0] opcode5 = instruction[6:2];
   
    always@(*) begin
        case(opcode5)
            `OPC_ARI_ITYPE_5:begin
                IMME_out = {{20{instruction[31]}},instruction[31:20]};
            end
            `OPC_LOAD_5:begin
                IMME_out = {{20{instruction[31]}},instruction[31:20]};
            end
            `OPC_STORE_5:begin
                IMME_out = {{20{instruction[31]}},instruction[31:25],instruction[11:7]}; 
            end
            `OPC_BRANCH_5:begin
                IMME_out = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
            end
            `OPC_LUI_5:begin
                IMME_out = instruction[31:12] << 12;
            end
            `OPC_AUIPC_5:begin
                IMME_out = instruction[31:12] << 12;
            end
            `OPC_JAL_5:begin
                IMME_out = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            `OPC_JALR_5:begin
                IMME_out = {{20{instruction[31]}},instruction[31:20]};
            end
            default:begin
                IMME_out = 32'd0;
            end
        endcase 
    end
endmodule
