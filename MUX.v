module mux_2input(in1, in2, sel, out);
  parameter LENGTH = 8;
  input sel;
  input [LENGTH-1:0] in1, in2;
  output [LENGTH-1:0] out;

  assign out = (sel == 0) ? in1 : in2;
endmodule // mux

module mux_3input(in1, in2, in3, sel, out);
  parameter LENGTH = 8;
  input [LENGTH-1:0] in1, in2, in3;
  input [1:0] sel;
  output [LENGTH-1:0] out;

  assign out = (sel == 2'd0) ? in1 :
               (sel == 2'd1) ? in2 : in3;
endmodule // mux

module mux_4input(in1, in2, in3, in4, sel, out);
  parameter LENGTH = 8;
  input [LENGTH-1:0] in1, in2, in3, in4;
  input [1:0] sel;
  output [LENGTH-1:0] out;

  assign out = sel[1] ? (sel[0] ? in4 : in3) : (sel[0] ? in2 : in1);
endmodule // mux

module mux_5input(in1, in2, in3, in4, in5, sel, out);
  parameter LENGTH = 8;
  input [LENGTH-1:0] in1, in2, in3, in4,in5;
  input [2:0] sel;
  output [LENGTH-1:0] out;

    assign out = (sel == 2'd0) ? in1 :
                 (sel == 2'd1) ? in2 :
                 (sel == 2'd2) ? in3 :
                 (sel == 2'd3) ? in4 : in5;
endmodule // mux