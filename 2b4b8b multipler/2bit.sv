module vedic_mult_2bit (
    input logic [1:0] a, b,
    output logic [3:0] out
);
    // Single bit multiplications (AND gates)
    logic [3:0] temp_prod; // For intermediate products
    
    // Multiply each bit with each bit
    assign temp_prod[0] = a[0] & b[0];                    // a0*b0
    assign temp_prod[1] = a[1] & b[0];                    // a1*b0
    assign temp_prod[2] = a[0] & b[1];                    // a0*b1
    assign temp_prod[3] = a[1] & b[1];                    // a1*b1
    
    // Final assembly with proper carries
    logic carry;
    assign out[0] = temp_prod[0];                         // LSB is direct
    assign {carry, out[1]} = temp_prod[1] + temp_prod[2]; // Middle terms with carry
    assign out[3:2] = temp_prod[3] + carry;               // MSB with carry from middle
endmodule
