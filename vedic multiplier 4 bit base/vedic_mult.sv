
module vedic_mult #(
  parameter WIDTH = 4
)(
  input  logic [WIDTH-1:0] a, b,
  output logic [2*WIDTH-1:0] out
);
   generate
    if (WIDTH == 4) begin : base_case  // Changed from WIDTH == 2
      // 4-bit vedic multiplier base case
      vedic_mult_4bit vm4(a, b, out);  // This replaces the previous 2-bit implementation
    end else begin : recursive_case
      // Recursive case for larger multipliers
      localparam HALF_WIDTH = WIDTH/2;
      
      logic [2*HALF_WIDTH-1:0] out_ved1, out_ved2, out_ved3, out_ved4;
      logic c1, c2, c3, or_carry;
      logic [2*HALF_WIDTH-1:0] cla_sum1, cla_sum2, cla_sum3;
      
      // Instantiate smaller vedic multipliers
      vedic_mult #(.WIDTH(HALF_WIDTH)) v1(a[HALF_WIDTH-1:0], b[HALF_WIDTH-1:0], out_ved1);
      vedic_mult #(.WIDTH(HALF_WIDTH)) v2(a[HALF_WIDTH-1:0], b[WIDTH-1:HALF_WIDTH], out_ved2);
      vedic_mult #(.WIDTH(HALF_WIDTH)) v3(a[WIDTH-1:HALF_WIDTH], b[HALF_WIDTH-1:0], out_ved3);
      vedic_mult #(.WIDTH(HALF_WIDTH)) v4(a[WIDTH-1:HALF_WIDTH], b[WIDTH-1:HALF_WIDTH], out_ved4);
      
      // CLA operations
      CLA #(.WIDTH(2*HALF_WIDTH)) cla1(out_ved2, out_ved3, 1'b0, cla_sum1, c1);
      
      logic [2*HALF_WIDTH-1:0] extended_out_ved1;
      assign extended_out_ved1 = {{HALF_WIDTH{1'b0}}, out_ved1[2*HALF_WIDTH-1:HALF_WIDTH]};
      CLA #(.WIDTH(2*HALF_WIDTH)) cla2(extended_out_ved1, cla_sum1, 1'b0, cla_sum2, c2);
      
      assign or_carry = c1 | c2; // Changed + to | for logical OR
      
      logic [2*HALF_WIDTH-1:0] extended_cla_sum2;
      assign extended_cla_sum2 = {{(HALF_WIDTH-1){1'b0}}, or_carry, cla_sum2[2*HALF_WIDTH-1:HALF_WIDTH]};
      CLA #(.WIDTH(2*HALF_WIDTH)) cla3(extended_cla_sum2, out_ved4, 1'b0, cla_sum3, c3);
      
      // Final output assembly
      assign out = {cla_sum3, cla_sum2[HALF_WIDTH-1:0], out_ved1[HALF_WIDTH-1:0]};
    end
  endgenerate
endmodule
