module vedic_mult #(parameter WIDTH = 32) (
    input logic [WIDTH-1:0] a, b,
    output logic [(2*WIDTH)-1:0] out
);
    generate
        if (WIDTH == 8) begin : base_case
            // Base case is 8-bit
            vedic_mult_8bit vm8 (.a(a), .b(b), .out(out));
        end else begin : recursive_case
            // Split operands into high and low halves
            localparam HALF_WIDTH = WIDTH / 2;
            
            wire [HALF_WIDTH-1:0] a_low, b_low;
            wire [HALF_WIDTH-1:0] a_high, b_high;
            wire [(2*HALF_WIDTH)-1:0] mul_ll, mul_lh, mul_hl, mul_hh;
            wire [(2*WIDTH)-1:0] term1, term2, term3, term4;
            
            assign a_low = a[HALF_WIDTH-1:0];
            assign a_high = a[WIDTH-1:HALF_WIDTH];
            assign b_low = b[HALF_WIDTH-1:0];
            assign b_high = b[WIDTH-1:HALF_WIDTH];
            
            // Recursive multiplication of sub-components
            vedic_mult #(HALF_WIDTH) vm_ll (
                .a(a_low),
                .b(b_low),
                .out(mul_ll)
            );
            
            vedic_mult #(HALF_WIDTH) vm_lh (
                .a(a_low),
                .b(b_high),
                .out(mul_lh)
            );
            
            vedic_mult #(HALF_WIDTH) vm_hl (
                .a(a_high),
                .b(b_low),
                .out(mul_hl)
            );
            
            vedic_mult #(HALF_WIDTH) vm_hh (
                .a(a_high),
                .b(b_high),
                .out(mul_hh)
            );
            
            // Properly align and combine the results
            assign term1 = mul_ll;
            assign term2 = {mul_lh, {HALF_WIDTH{1'b0}}};
            assign term3 = {mul_hl, {HALF_WIDTH{1'b0}}};
            assign term4 = {mul_hh, {WIDTH{1'b0}}};
            
            assign out = term1 + term2 + term3 + term4;
        end
    endgenerate
endmodule
