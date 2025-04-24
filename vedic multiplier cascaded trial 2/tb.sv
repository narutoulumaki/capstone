module vedic_mult_tb;
  // Test signals for 4-bit multiplier
  logic [3:0] a, b;
  logic [7:0] result;
  
  // Instantiate 4-bit Vedic multiplier
  vedic_mult_4bit dut (
    .a(a),
    .b(b),
    .out(result)
  );
  
  // Test procedure
  initial begin
    // Test case 1
    a = 4'b0011; // 3
    b = 4'b0101; // 5
    #10;
    $display("Test: %d * %d = %d", a, b, result);
    
    // Test case 2
    a = 4'b1010; // 10
    b = 4'b0110; // 6
    #10;
    $display("Test: %d * %d = %d", a, b, result);
    
    // Test case 3
    a = 4'b1111; // 15
    b = 4'b1111; // 15
    #10;
    $display("Test: %d * %d = %d", a, b, result);
    
    $finish;
  end
endmodule
