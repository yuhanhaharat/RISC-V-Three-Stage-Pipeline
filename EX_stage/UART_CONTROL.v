`timescale 1ns / 1ps
`include "Opcode.vh"

module UART_CONTROL(instruction, DataB, ALU_result, data_out_valid_rx, data_out_rx, 
                    data_in_ready_tx, data_load_formatted, data_out_ready_rx, data_in_valid_tx, data_store_tx);
                    
        //inputs
        input [31:0] instruction; 
        input [31:0] DataB; 
        input [31:0] ALU_result; 
        input data_out_valid_rx; 
        input [7:0] data_out_rx;  
        input data_in_ready_tx; 
        //outputs
        output reg [31:0] data_load_formatted;  
        output reg [7:0] data_store_tx; 
        output reg data_out_ready_rx; 
        output reg data_in_valid_tx;
        
        wire [6:0] opcode7 = instruction[6:0];

        always@(*) begin
            if (ALU_result == 32'h80000000 && opcode7 == `OPC_LOAD) begin              // load control signals to rd
                data_load_formatted = {30'b0, data_out_valid_rx, data_in_ready_tx};  
                data_out_ready_rx = 1'd0; 
                data_in_valid_tx  = 1'd0; 
                data_store_tx     = 8'd0; 
            end else if (ALU_result == 32'h80000004 && opcode7 == `OPC_LOAD) begin     // load data to rd
                data_load_formatted = {24'b0, data_out_rx};  
                data_out_ready_rx = 1'd1; 
                data_in_valid_tx  = 1'd0; 
                data_store_tx     = 8'd0; 
            end else if (ALU_result == 32'h80000008 && opcode7 == `OPC_STORE) begin   // store data to rs
                data_load_formatted = 32'd0;  
                data_out_ready_rx = 1'd0; 
                data_in_valid_tx  = 1'd1; 
                data_store_tx     = DataB[7:0]; 
            end else begin
                data_load_formatted = 32'd0;  
                data_out_ready_rx = 1'd0; 
                data_in_valid_tx  = 1'd0; 
                data_store_tx     = 8'd0; 
            end   
        end
endmodule
