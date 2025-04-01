module partial_product_generator (
    input logic [31:0] multiplicand, 
    input logic [1:0] op,
    input logic neg,
    input logic [5:0] shift_amount,  // Shift amount for Booth iteration
    output logic [63:0] partial_product
);
    logic [31:0] product;
    
    always_comb begin
        case (op)
            2'b00: product = 32'b0;                   // 0
            2'b01: product = multiplicand;            // +X
            2'b11: product = multiplicand << 1;       // +2X
            2'b10: product = 32'b0;                   // Should not occur
        endcase
        partial_product = (neg) ? -product : product;
        partial_product = partial_product << shift_amount;  // Shift based on Booth position
    end
endmodule

