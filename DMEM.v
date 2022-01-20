module DMEM(clk,dmem_addra,dmem_douta,dmem_dina,dmem_wea);

     input clk;
     input [13:0] dmem_addra;
     input [31:0] dmem_dina;
     output [31:0] dmem_douta;
     input [3:0] dmem_wea;
    
    // Data Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    SYNC_RAM_WBE #(
      .AWIDTH(14),
      .DWIDTH(32)) dmem (
      .q(dmem_douta),    // output
      .d(dmem_dina),     // input
      .addr(dmem_addra), // input
      .wbe(dmem_wea),    // input
      .en(1'b1),
      .clk(clk));

endmodule
