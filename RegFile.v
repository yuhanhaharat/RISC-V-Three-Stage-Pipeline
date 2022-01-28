module RegFile(clk,Reg_WE,DataA_new,DataB_new,DataD,AddrA,AddrB,AddrD);
    input clk;
    input Reg_WE;
    input [31:0] DataD;
    input [4:0] AddrA;
    input [4:0]  AddrB;
    input [4:0]  AddrD;
    output [31:0] DataA_new;
    output [31:0] DataB_new;

    wire Reg_WE_new;
    assign Reg_WE_new = (AddrD == 5'd0) ? 1'b0 : Reg_WE;
    
    wire [31:0] DataA,DataB;
    assign DataA_new = (AddrA == 5'd0) ? 32'd0 : DataA;
    assign DataB_new = (AddrB == 5'd0) ? 32'd0 : DataB;

    ASYNC_RAM_1W2R #(.DWIDTH(32),.AWIDTH(5),.DEPTH(32)) rf   (.d0(DataD),
                                                              .addr0(AddrD),
                                                              .we0(Reg_WE_new),
                                                              .q1(DataA),
                                                              .addr1(AddrA),
                                                              .q2(DataB),
                                                              .addr2(AddrB),
                                                              .clk(clk));

endmodule
