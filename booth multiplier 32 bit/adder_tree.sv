module adder_tree (
    input logic clk,
    input logic [63:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7,
    output logic [63:0] product
);
    logic [63:0] sum1, sum2, sum3, sum4;
    
    always_ff @(posedge clk) begin
        sum1 = pp0 + pp1;
        sum2 = pp2 + pp3;
        sum3 = pp4 + pp5;
        sum4 = pp6 + pp7;
        
        sum1 = sum1 + sum2;
        sum3 = sum3 + sum4;
        
        product = sum1 + sum3;
    end
endmodule
