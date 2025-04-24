module vedic_mult_4bit (
    input logic [3:0] a, b,
    output logic [7:0] out
);
    // Partial products from 2x2 multiplications
    logic [3:0] pp0, pp1, pp2, pp3;
    
    // Instantiate 2-bit multipliers for each quadrant
    vedic_mult_2bit v0(.a(a[1:0]), .b(b[1:0]), .out(pp0));
    vedic_mult_2bit v1(.a(a[1:0]), .b(b[3:2]), .out(pp1));
    vedic_mult_2bit v2(.a(a[3:2]), .b(b[1:0]), .out(pp2));
    vedic_mult_2bit v3(.a(a[3:2]), .b(b[3:2]), .out(pp3));
    
    // Combine partial products with proper alignment
    logic [7:0] sum1, sum2;
    logic [3:0] temp_sum;
    logic carry;
    
    // First level addition
    assign out[1:0] = pp0[1:0];  // Lowest 2 bits come directly from pp0
    
    // Add middle terms (pp0[3:2] + pp1[1:0] + pp2[1:0])
    assign {carry, temp_sum} = {2'b00, pp0[3:2]} + {2'b00, pp1[1:0]} + {2'b00, pp2[1:0]};
    
    // Second level with carry
    assign out[3:2] = temp_sum[1:0];
    assign out[7:4] = pp3 + pp1[3:2] + pp2[3:2] + {2'b00, temp_sum[3:2]};
endmodule
