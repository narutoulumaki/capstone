
module vedic_mult_8bit (
    input logic [7:0] a, b,
    output logic [15:0] out
);
    // Partial products from 4x4 multiplications
    logic [7:0] pp0, pp1, pp2, pp3;
    
    // Instantiate 4-bit multipliers for each quadrant
    vedic_mult_4bit v0(.a(a[3:0]), .b(b[3:0]), .out(pp0));
    vedic_mult_4bit v1(.a(a[3:0]), .b(b[7:4]), .out(pp1));
    vedic_mult_4bit v2(.a(a[7:4]), .b(b[3:0]), .out(pp2));
    vedic_mult_4bit v3(.a(a[7:4]), .b(b[7:4]), .out(pp3));
    
    // Combine partial products with proper alignment
    logic [15:0] sum1, sum2;
    
    // First level alignment and addition
    assign out[3:0] = pp0[3:0];  // Lowest 4 bits come directly from pp0
    
    // Combine remaining parts with proper shifts
    assign sum1 = {8'b0, pp0[7:4]} + {4'b0, pp1[7:0], 4'b0} + {4'b0, pp2[7:0], 4'b0};
    assign sum2 = sum1 + {pp3[7:0], 8'b0};
    
    assign out[15:4] = sum2[15:4];
endmodule
