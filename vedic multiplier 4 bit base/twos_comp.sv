module twos_comp #(
  parameter WIDTH = 32
)(
  input  logic [WIDTH-1:0] in,
  input  logic en,
  output logic [WIDTH-1:0] out
);
  always_comb begin
    out = en ? (~in + 1'b1) : in;
  end
endmodule
