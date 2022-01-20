module RegFile(clk,Reg_WE,DataA,DataB,DataD,AddrA,AddrB,AddrD);
    input clk;
    input Reg_WE;
    input [31:0] DataD;
    input [4:0] AddrA;
    input [4:0]  AddrB;
    input [4:0]  AddrD;
    output [31:0] DataA;
    output [31:0] DataB;

    ASYNC_RAM_1W2R #(.DWIDTH(32),.AWIDTH(5),.DEPTH(32)) rf   (.d0(DataD),
                                                              .addr0(AddrD),
                                                              .we0(Reg_WE),
                                                              .q1(DataA),
                                                              .addr1(AddrA),
                                                              .q2(DataB),
                                                              .addr2(AddrB),
                                                              .clk(clk));
    //reading from register0 always returns 0.
    
endmodule
