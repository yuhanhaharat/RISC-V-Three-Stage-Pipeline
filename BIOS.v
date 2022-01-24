module BIOS(clk,bios_addra,bios_addrb,bios_douta,bios_doutb);
    localparam BIOS_AWIDTH = 12;
    localparam BIOS_DWIDTH = 32;
    
    input clk;
    input [BIOS_AWIDTH-1:0] bios_addra, bios_addrb;
    output [BIOS_DWIDTH-1:0] bios_douta, bios_doutb;
    wire [3:0]  bios_wea,bios_web;
    wire [31:0] bios_dina,bios_dinb;
    
    assign bios_web = 4'd0;
    assign bios_wea = 4'd0;
    assign bios_dina = 32'd0;
    assign bios_dinb = 32'd0;
    
    // BIOS Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    SYNC_RAM_DP_WBE #(
      .AWIDTH(BIOS_AWIDTH),
      .DWIDTH(BIOS_DWIDTH)
    ) imem (
      .q0(bios_douta),    // output
      .d0(bios_dina),     // input
      .addr0(bios_addra), // input
      .wbe0(bios_wea),    // input
      .en0(1'b1),
        
      .q1(bios_doutb),    // output
      .d1(bios_dinb),     // input
      .addr1(bios_addrb), // input
      .wbe1(bios_web),    // input
      .en1(1'b1),
  
      .clk(clk));
    
endmodule
