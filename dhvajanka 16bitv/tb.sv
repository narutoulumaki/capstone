module cascaded_vedic_divider_16bit_tb;
    // Parameters
    parameter WIDTH = 32;
    
    // Signals
    logic clk;
    logic rst_n;
    logic start;
    logic [WIDTH-1:0] dividend;
    logic [WIDTH-1:0] divisor;
    logic [WIDTH-1:0] quotient;
    logic [WIDTH-1:0] remainder;
    logic done;
    
    // Instantiate the DUT
    cascaded_vedic_divider_16bit #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        rst_n = 0;
        start = 0;
        dividend = 0;
        divisor = 0;
        
        #10 rst_n = 1;
        
        // Test case 1: 12540000 ÷ 98
        #10;
        dividend = 12540000;
        divisor = 98;
        start = 1;
        #10 start = 0;
        
        wait(done);
        #10;
        $display("Test 1: %d ÷ %d = %d remainder %d (expected: ~128,000)", 
                 dividend, divisor, quotient, remainder);
        
        // Test case 2: 8610000 ÷ 700
        #10;
        dividend = 8610000;
        divisor = 700;
        start = 1;
        #10 start = 0;
        
        wait(done);
        #10;
        $display("Test 2: %d ÷ %d = %d remainder %d (expected: ~12,300)", 
                 dividend, divisor, quotient, remainder);
        
        // Add more test cases as needed
        
        #100 $finish;
    end
    
    // Optional: Add waveform dumping if using a simulator that supports it
    // initial begin
    //     $dumpfile("cascaded_vedic_divider.vcd");
    //     $dumpvars(0, cascaded_vedic_divider_16bit_tb);
    // end
    
endmodule
