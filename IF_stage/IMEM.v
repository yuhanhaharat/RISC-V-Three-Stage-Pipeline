module IMEM(clk,imem_addra,imem_addrb,imem_douta,imem_doutb,imem_dina,imem_dinb,imem_wea);
    localparam IMEM_AWIDTH = 14;
    localparam IMEM_DWIDTH = 32;
    
    input clk;
    input [IMEM_AWIDTH-1:0] imem_addra, imem_addrb;
    input [IMEM_DWIDTH-1:0] imem_dina, imem_dinb;
    input [3:0] imem_wea;
    output [IMEM_DWIDTH-1:0] imem_douta, imem_doutb;
    wire [3:0] imem_web;
    
    assign imem_web = 4'd0;
    
    // Instruction Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    SYNC_RAM_DP_WBE #(
      .AWIDTH(IMEM_AWIDTH),
      .DWIDTH(IMEM_DWIDTH)
    ) imem (
      .q0(imem_douta),    // output
      .d0(imem_dina),     // input
      .addr0(imem_addra), // input
      .wbe0(imem_wea),    // input
      .en0(1'b1),
  
      .q1(imem_doutb),    // output
      .d1(imem_dinb),     // input
      .addr1(imem_addrb), // input
      .wbe1(imem_web),    // input
      .en1(1'b1),
  
      .clk(clk)
    );
    
endmodule
