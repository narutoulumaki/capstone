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
  
  // Get absolute values (inline implementation instead of module instances)
  assign abs_a = a[WIDTH-1] ? (~a + 1'b1) : a;
  assign abs_b = b[WIDTH-1] ? (~b + 1'b1) : b;
  
  // Perform unsigned multiplication
  mult_engine #(.WIDTH(WIDTH)) mult_core(abs_a, abs_b, unsigned_result);
  
  // Apply sign to result if needed (inline implementation)
  assign out = output_sign ? (~unsigned_result + 1'b1) : unsigned_result;
endmodule
