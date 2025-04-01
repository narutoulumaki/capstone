module signed_vedic_mult_tb();
  logic [31:0] a, b;
  logic [63:0] out;
  
  signed_vedic_mult #(.WIDTH(32)) svm(a, b, out);
  
  initial begin
    // Test case 1: 2 * 3 = 6 (positive * positive)
    a = 32'h00000002;
    b = 32'h00000003;
    #50;
    
    // Test case 2: -2 * 3 = -6 (negative * positive)
    a = 32'hFFFFFFFE;
    b = 32'h00000003;
    #50;
    
    // Test case 3: 2 * -3 = -6 (positive * negative)
    a = 32'h00000002;
    b = 32'hFFFFFFFD;
    #50;
    
    // Test case 4: -2 * -3 = 6 (negative * negative)
    a = 32'hFFFFFFFE;
    b = 32'hFFFFFFFD;
    #50;
    
    $finish;
  end
endmodule
