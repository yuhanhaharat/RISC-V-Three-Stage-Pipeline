`include "Opcode.vh"

module ALU(DataA,DataB,ALUsel,instruction,result);
    input [31:0] DataA;
    input [31:0] DataB;
    //ALUsel[3]:bit30 from inst; ALUsel[2:0]:func3 from inst
    input [3:0]  ALUsel;
    input [31:0] instruction;        
    output reg [31:0] result;
    
    wire [2:0] func3 = ALUsel[2:0];
    wire inst_bit30 = ALUsel[3];
    wire [4:0] shamt = instruction[24:20];
    wire op_bit5 = instruction[4];

    always@(*) begin
        case(func3)
            //Add or Sub 
           `FNC_ADD_SUB:begin    
                if(inst_bit30 == `FNC2_ADD) result = DataA + DataB;
                else result = DataA - DataB;
           end
           //Performs logical left shift on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2.        
           `FNC_SLL: begin
                if(op_bit5 == 1'b0) result = DataA << shamt;
                else result = DataA << DataB[4:0];
           end
           //Place the value 1 in register rd if register rs1 is less than register rs2 when both are treated as signed numbers, else 0 is written to rd.
           `FNC_SLT:begin
                if ($signed(DataA) < $signed(DataB)) result = 1'b1;
                else result = 1'b0;
           end
           //Place the value 1 in register rd if register rs1 is less than register rs2 when both are treated as unsigned numbers, else 0 is written to rd.
           `FNC_SLTU: begin
               if (DataA < DataB) result = 1'b1;
               else result = 1'b0;
           end
           //Performs bitwise XOR on registers rs1 and rs2 and place the result in rd
           `FNC_XOR: result = DataA ^ DataB;
           //Performs bitwise OR on registers rs1 and rs2 and place the result in rd
           `FNC_OR: result = DataA | DataB;
           //Performs bitwise AND on registers rs1 and rs2 and place the result in rd
           `FNC_AND: result = DataA | DataB;
           //Shift right operation
           `FNC_SRL_SRA:begin
                if(op_bit5 == 1'b0)begin
                        //SRL:Logical right shift on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2
                        if (inst_bit30 == 1'b0) result = DataA >> shamt;
                        //SRA:Performs arithmetic right shift on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2
                        else result = $signed(DataA) >>> shamt;
                end else begin
                    //SRL:Logical right shift on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2
                    if (inst_bit30 == 1'b0) result = DataA >> DataB[4:0];
                    //SRA:Performs arithmetic right shift on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2
                    else result = $signed(DataA) >>> DataB[4:0];
                end
          end
          default: result = 0;
        endcase
    end
endmodule
