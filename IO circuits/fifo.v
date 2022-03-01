module fifo #(
  parameter WIDTH    = 32, // data width is 32-bit
  parameter LOGDEPTH = 3   // 2^3 = 8 entries
) (
  input clk,
  input rst,

  // Write interface (enqueue)
  input  enq_valid,
  input  [WIDTH-1:0] enq_data,
  output enq_ready,

  // Read interface (dequeue)
  output deq_valid,
  output [WIDTH-1:0] deq_data,
  input deq_ready
);

  // For simplicity, we deal with FIFO with depth values of power of two.
    localparam DEPTH = (1 << LOGDEPTH);
    localparam LOGDEPTH_ASST = LOGDEPTH+1;
    
    // Dual-port Memory
    // Use port0 for write, port1 for read
    wire [LOGDEPTH-1:0] buffer_addr0, buffer_addr1;
    wire [WIDTH-1:0] buffer_d0, buffer_d1, buffer_q0, buffer_q1;
    wire buffer_we0, buffer_we1;

    // You can choose to use either ASYNC read or SYNC read memory for buffer storage of your FIFO
    // It is suggested that you should start with ASYNC read, since it will be simpler

    // This memory requires 1-cycle write update
    // Read can be performed immediately
    ASYNC_RAM_DP #(.AWIDTH(LOGDEPTH), .DWIDTH(WIDTH), .DEPTH(DEPTH)) buffer (
        .q0(buffer_q0), .d0(buffer_d0), .addr0(buffer_addr0), .we0(buffer_we0),
        .q1(buffer_q1), .d1(buffer_d1), .addr1(buffer_addr1), .we1(buffer_we1),
        .clk(clk));

    // This memory requires 1-cycle write, and 1-cycle read
//    XILINX_SYNC_RAM_DP #(.AWIDTH(LOGDEPTH), .DWIDTH(WIDTH), .DEPTH(DEPTH)) buffer (
//        .q0(buffer_q0), .d0(buffer_d0), .addr0(buffer_addr0), .we0(buffer_we0),
//        .q1(buffer_q1), .d1(buffer_d1), .addr1(buffer_addr1), .we1(buffer_we1),
//        .clk(clk), .rst(rst));

    // Disable write on port1
    assign buffer_we1 = 1'b0;
    assign buffer_d1  = 0;
    
    wire [LOGDEPTH_ASST-1:0] read_ptr_val, read_ptr_next;
    wire read_ptr_ce;
    wire [LOGDEPTH_ASST-1:0] write_ptr_val, write_ptr_next;
    wire write_ptr_ce;
    wire enq_fire,deq_fire;
    REGISTER_R_CE #(.N(LOGDEPTH_ASST)) read_ptr_reg  (
        .q(read_ptr_val),
        .d(read_ptr_next),
        .ce(read_ptr_ce),
        .rst(rst), .clk(clk));
    REGISTER_R_CE #(.N(LOGDEPTH_ASST)) write_ptr_reg (
        .q(write_ptr_val),
        .d(write_ptr_next),
        .ce(write_ptr_ce),
        .rst(rst), .clk(clk));
        
    assign read_ptr_next = read_ptr_val + 1;
    assign read_ptr_ce = deq_fire;
    
    assign write_ptr_next = write_ptr_val + 1;
    assign write_ptr_ce = enq_fire;
    
    assign buffer_addr0 = write_ptr_val[LOGDEPTH_ASST-2:0];
    assign buffer_addr1 = read_ptr_val[LOGDEPTH_ASST-2:0];
    
    assign buffer_we0 = enq_fire;
    assign buffer_d0 = enq_data;
    
    assign deq_data = buffer_q1;
    
    wire MSB,full,empty;
    assign MSB = (write_ptr_val[LOGDEPTH_ASST-1] == read_ptr_val[LOGDEPTH_ASST-1]) ? 1'b1:1'b0;
    assign full = (MSB == 1'b0) && (write_ptr_val[LOGDEPTH_ASST-2:0] == read_ptr_val[LOGDEPTH_ASST-2:0]);
    assign empty = (MSB == 1'b1) && (write_ptr_val[LOGDEPTH_ASST-2:0] == read_ptr_val[LOGDEPTH_ASST-2:0]);
            
    assign enq_ready = ~full; //FIFO full
    assign deq_valid = ~empty; //FIFO empty

    assign enq_fire = enq_valid && enq_ready;
    assign deq_fire = deq_valid && deq_ready;

endmodule
