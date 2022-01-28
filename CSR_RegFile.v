module CSR_RegFile(clk,CSR_WE,din,Addr,dout);
    input clk;
    input CSR_WE;
    input [11:0] Addr;
    input [31:0] din;
    output [31:0] dout;
        
    //ASYNC_RAM with one write/read port
    ASYNC_RAM #(.DWIDTH(32),.AWIDTH(12)) csr_rf   (.q(dout),
                                                  .d(din),
                                                  .addr(Addr),
                                                  .we(CSR_WE),
                                                  .clk(clk));

endmodule
