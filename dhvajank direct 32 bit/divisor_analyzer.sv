module divisor_analyzer #(
    parameter WIDTH = 16
)(
    input logic [WIDTH-1:0] divisor,
    output logic [7:0] power10_value,
    output logic signed [8:0] difference,
    output logic is_near_power10
);
    // Find the nearest power of 10
    always_comb begin
        // Default values
        power10_value = 8'd10;  // Default to 10
        difference = 9'd0;
        is_near_power10 = 1'b0;
        
        if (divisor < 20) begin
            power10_value = 8'd10;
            difference = signed'(power10_value) - signed'(divisor);
            is_near_power10 = (divisor > 7 && divisor < 13);
        end
        else if (divisor < 200) begin
            power10_value = 8'd100;
            difference = signed'(power10_value) - signed'(divisor);
            is_near_power10 = (divisor > 70 && divisor < 130);
        end
        else if (divisor < 2000) begin
            power10_value = 8'd1000;
            difference = signed'(power10_value) - signed'(divisor);
            is_near_power10 = (divisor > 700 && divisor < 1300);
        end
        // Additional ranges can be added as needed
    end
endmodule
