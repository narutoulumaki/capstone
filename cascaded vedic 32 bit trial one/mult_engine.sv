module mult_engine #(
  parameter WIDTH = 32
)(
  input  logic [WIDTH-1:0] a, b,
  output logic [2*WIDTH-1:0] out
);
  generate
    if (WIDTH <= 8) begin : direct_mult
      // Direct multiplication for 8-bit and smaller - uses fewer ports
      assign out = a * b;
    end else begin : divide_conquer
      localparam HALF_WIDTH = WIDTH/2;
      
      // Split inputs into high and low parts
      logic [HALF_WIDTH-1:0] a_low, b_low;
      logic [HALF_WIDTH-1:0] a_high, b_high;
      
      // Results of sub-multiplications
      logic [WIDTH-1:0] low_result, mid1_result, mid2_result, high_result;
      logic [WIDTH:0] mid_sum;  // +1 bit for carry
      logic [2*WIDTH-1:0] combined_result;
      
      // Split the inputs
      assign a_low = a[HALF_WIDTH-1:0];
      assign a_high = a[WIDTH-1:HALF_WIDTH];
      assign b_low = b[HALF_WIDTH-1:0];
      assign b_high = b[WIDTH-1:HALF_WIDTH];
      
      // Perform 4 multiplications of half the size
      mult_engine #(.WIDTH(HALF_WIDTH)) low_mult(
        .a(a_low),
        .b(b_low),
        .out(low_result)
      );
      
      mult_engine #(.WIDTH(HALF_WIDTH)) mid1_mult(
        .a(a_low),
        .b(b_high),
        .out(mid1_result)
      );
      
      mult_engine #(.WIDTH(HALF_WIDTH)) mid2_mult(
        .a(a_high),
        .b(b_low),
        .out(mid2_result)
      );
      
      mult_engine #(.WIDTH(HALF_WIDTH)) high_mult(
        .a(a_high),
        .b(b_high),
        .out(high_result)
      );
      
      // Combine results with shifts (equivalent to Vedic but with fewer adders)
      assign mid_sum = mid1_result + mid2_result;
      
      // Final combination with efficient shifts
      assign combined_result = {high_result, {HALF_WIDTH{1'b0}}} + 
                               {mid_sum, {HALF_WIDTH{1'b0}}} +
                               low_result;
      
      // Output the result
      assign out = combined_result;
    end
  endgenerate
endmodule
