`include "Opcode.vh"

module LOAD_UNIT(load_type,wanted_byte,raw_din,dout);
    input [2:0] load_type;
    input [1:0] wanted_byte;
    input [31:0] raw_din;
    output reg [31:0] dout;

     always@(*) begin
       case(load_type)
          `FNC_LB:begin
                case (wanted_byte)
                      2'b00: dout = { {24{raw_din[7]}}, raw_din[7:0]};
                      2'b01: dout = { {24{raw_din[15]}}, raw_din[15:8]};
                      2'b10: dout = { {24{raw_din[23]}}, raw_din[23:16]};
                      2'b11: dout = { {24{raw_din[31]}}, raw_din[31:24]};
                      default: dout = 32'b0;
                endcase
          end
          `FNC_LH: begin
                      case (wanted_byte)
                      2'b00: dout = { {16{raw_din[15]}}, raw_din[15:0] };
                      2'b01: dout = { {16{raw_din[15]}}, raw_din[15:0] };
                      2'b10: dout = { {16{raw_din[31]}}, raw_din[31:16] };
                      2'b11: dout = { {16{raw_din[31]}}, raw_din[31:16] };
                      default: dout = 32'b0;
                      endcase
                  end  
          `FNC_LW: dout = raw_din;
          `FNC_LBU: begin
                      case (wanted_byte)
                      2'b00: dout = { {24{1'b0}}, raw_din[7:0] };
                      2'b01: dout = { {24{1'b0}}, raw_din[15:8] };
                      2'b10: dout = { {24{1'b0}}, raw_din[23:16] };
                      2'b11: dout = { {24{1'b0}}, raw_din[31:24] };
                      default: dout = 32'b0;
                      endcase
                  end
           `FNC_LHU: begin
                      case (wanted_byte)
                      2'b00: dout = { {16{1'b0}}, raw_din[15:0] };
                      2'b01: dout = { {16{1'b0}}, raw_din[15:0] };
                      2'b10: dout = { {16{1'b0}}, raw_din[31:16] };
                      2'b11: dout = { {16{1'b0}}, raw_din[31:16] };
                      default: dout = 32'b0;
                      endcase
                  end
           default: dout = 32'd0;
       endcase
     end
endmodule
