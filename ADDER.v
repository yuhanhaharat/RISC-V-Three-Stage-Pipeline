module adder(in1, in2, out);
  parameter LENGTH = 8;
  input [LENGTH-1:0] in1, in2;
  output [LENGTH-1:0] out;
  assign out = in1 + in2;
endmodule // adder
