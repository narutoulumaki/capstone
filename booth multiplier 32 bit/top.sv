module booth_multiplier_top (
    input logic clk,
    input logic [31:0] mcand,
    input logic [31:0] mplier,
    output logic [63:0] product
);
    logic [2:0] booth_bits [0:7];
    logic [1:0] op [0:7];
    logic neg [0:7];
    logic [63:0] partial_products [0:7];
    
    // Generate Booth Encodings
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            assign booth_bits[i] = {mplier[2*i+2], mplier[2*i+1], mplier[2*i]};
            booth_encoder BE (.booth_in(booth_bits[i]), .op(op[i]), .neg(neg[i]));
        end
    endgenerate

    // Generate Partial Products
    generate
        for (i = 0; i < 8; i++) begin
            partial_product_generator PPG (
                .multiplicand(mcand),
                .op(op[i]),
                .neg(neg[i]),
                .shift_amount(i * 2),
                .partial_product(partial_products[i])
            );
        end
    endgenerate

    // Sum Partial Products
    adder_tree AT (.clk(clk), .pp0(partial_products[0]), .pp1(partial_products[1]),
                   .pp2(partial_products[2]), .pp3(partial_products[3]),
                   .pp4(partial_products[4]), .pp5(partial_products[5]),
                   .pp6(partial_products[6]), .pp7(partial_products[7]),
                   .product(product));
endmodule
