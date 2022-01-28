`include "Opcode.vh"

module BRANCH_UNIT(rst,DataA,DataB,instruction,should_br);
    input rst;
    input [31:0] DataA;
    input [31:0] DataB;
    input [31:0] instruction;
    output reg should_br;
    
    wire [6:0] opcode7 = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];

    always @(*) begin
        if (opcode7 == `OPC_BRANCH) begin
            case (funct3)
            `FNC_BEQ: should_br = (DataA == DataB);
            `FNC_BNE: should_br = (DataA != DataB);
            `FNC_BLT: should_br = ($signed(DataA) < $signed(DataB));
            `FNC_BGE: should_br = ($signed(DataA) >= $signed(DataB));
            `FNC_BLTU: should_br = (DataA < DataB);
            `FNC_BGEU: should_br = (DataA >= DataB);
            default: should_br = 1'b0;
            endcase
        end else if (opcode7 == `OPC_JALR) begin
            should_br = 1'b1;
        end else begin
            should_br = 1'b0;
        end
    end
endmodule
