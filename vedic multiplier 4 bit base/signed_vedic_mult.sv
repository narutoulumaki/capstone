module signed_vedic_mult #(
  parameter WIDTH = 32
)(
  input  logic [WIDTH-1:0] a, b,
  output logic [2*WIDTH-1:0] out
);
  logic [WIDTH-1:0] abs_a, abs_b;
  logic [2*WIDTH-1:0] unsigned_result;
  logic output_sign;
  
  // Determine if result should be negative
  assign output_sign = a[WIDTH-1] ^ b[WIDTH-1];
  
  // Get absolute values
  twos_comp #(.WIDTH(WIDTH)) tc_a(a, a[WIDTH-1], abs_a);
  twos_comp #(.WIDTH(WIDTH)) tc_b(b, b[WIDTH-1], abs_b);
  
  // Perform unsigned multiplication
  vedic_mult #(.WIDTH(WIDTH)) vm(abs_a, abs_b, unsigned_result);
  
  // Apply sign to result if needed
  twos_comp #(.WIDTH(2*WIDTH)) tc_out(unsigned_result, output_sign, out);
endmodule
