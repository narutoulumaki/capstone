module booth_multiplier_32bit (
    input logic [31:0] multiplicand, multiplier,
    output logic [63:0] product
);
    logic [33:0] partial_products[15:0];  // 16 partial products
    logic [63:0] sum;
    logic [33:0] shifted_product;

    // Sign-extend the multiplicand
    logic [32:0] signed_multiplicand;
    assign signed_multiplicand = {multiplicand[31], multiplicand};

    // Generate partial products using Booth encoding
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : booth_encoding
            booth_encoder enc (
                .booth_bits({multiplier[(2*i)+1], multiplier[2*i], (i == 0) ? 1'b0 : multiplier[(2*i)-1]}),
                .multiplicand(signed_multiplicand),
                .partial_product(partial_products[i])
            );
        end
    endgenerate

    // Shift and accumulate results
    assign sum = 0;  // Initialize sum
    always_comb begin
        for (int j = 0; j < 16; j = j + 1) begin
            sum = sum + (partial_products[j] << (2 * j));
        end
    end

    assign product = sum;
endmodule
