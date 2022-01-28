`timescale 1ns / 1ps

module JUMP_GEN(instruction,jump_addr,PC);
    input [31:0] instruction;
    output [31:0] jump_addr;
    input [31:0] PC;
    
    wire [31:0] offset;
    assign offset = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    assign jump_addr = PC + offset; 
    
endmodule
