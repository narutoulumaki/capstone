module vedic_mult_2bit (
    input logic [1:0] a, b,
    output logic [3:0] out
);
    logic [3:0] temp_prod;

    assign temp_prod[0] = a[0] & b[0];                   
    assign temp_prod[1] = a[1] & b[0];                   
    assign temp_prod[2] = a[0] & b[1];                   
    assign temp_prod[3] = a[1] & b[1];                    
    
    logic carry;
    assign out[0] = temp_prod[0];                        
    assign {carry, out[1]} = temp_prod[1] + temp_prod[2];
    assign out[3:2] = temp_prod[3] + carry;               
endmodule
