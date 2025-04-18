// Module for Dhvajanka computation for 8-bit divider
module dhvajanka_compute_8bit (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [7:0] dividend,
    input logic [7:0] power10_value,
    input logic signed [8:0] difference,
    input logic [2:0] max_iterations,
    output logic [7:0] quotient,
    output logic [7:0] remainder,
    output logic done
);
    // Internal registers
    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_CALCULATING,
        STATE_DONE
    } calc_state_t;
    
    calc_state_t curr_state, next_state;
    
    logic [7:0] current_term;
    logic [7:0] running_sum;
    logic [2:0] iteration;
    logic [15:0] mult_result; // Extended precision for multiplication
    logic signed [8:0] abs_diff;
    logic [15:0] div_result;  // Intermediate result for division operations
    
    // State machine - sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= STATE_IDLE;
        else
            curr_state <= next_state;
    end
    
    // State machine - combinational logic
    always_comb begin
        next_state = curr_state;
        
        case (curr_state)
            STATE_IDLE: begin
                if (start)
                    next_state = STATE_CALCULATING;
            end
            
            STATE_CALCULATING: begin
                if (iteration >= max_iterations)
                    next_state = STATE_DONE;
            end
            
            STATE_DONE: begin
                next_state = STATE_IDLE;
            end
        endcase
    end
    
    // Get absolute value of difference
    assign abs_diff = (difference < 0) ? -difference : difference;
    
    // Function to divide by powers of 10 more efficiently
    function logic [7:0] div_by_power10;
        input logic [7:0] value;
        input logic [7:0] power;
        logic [7:0] result;
    begin
        if (power == 8'd10)
            // Division by 10 can be approximated as: (value*205)>>11
            // 205/2048 ≈ 0.100098, which is very close to 0.1
            result = ((16'h00CD * 16'(value)) >> 11);
        else if (power == 8'd100)
            // Division by 100 can be approximated as: (value*41)>>12
            // 41/4096 ≈ 0.01001, which is very close to 0.01
            result = ((16'h0029 * 16'(value)) >> 12);
        else
            result = value / power; // Fallback for other cases
        
        return result;
    end
    endfunction
    
    // Main computation logic - split across more clock cycles
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_term <= '0;
            running_sum <= '0;
            iteration <= '0;
            quotient <= '0;
            remainder <= '0;
            done <= 1'b0;
            mult_result <= '0;
            div_result <= '0;
        end
        else begin
            case (curr_state)
                STATE_IDLE: begin
                    if (start) begin
                        // Initialize for calculation
                        iteration <= '0;
                        done <= 1'b0;
                        
                        // First step: dividend / power10 (using optimized division)
                        current_term <= div_by_power10(dividend, power10_value);
                        running_sum <= div_by_power10(dividend, power10_value);
                    end
                end
                
                STATE_CALCULATING: begin
                    iteration <= iteration + 1'b1;
                    
                    // Stage 1: Calculate multiplication result
                    mult_result <= (current_term * abs_diff);
                    
                    // Stage 2: Calculate division by power10_value (pipelined)
                    if (iteration > 0) begin
                        div_result <= div_by_power10(mult_result[7:0], power10_value);
                        
                        // Stage 3: Update running sum based on the sign of difference
                        if (difference > 0) begin
                            // Divisor is below power of 10 (e.g. 98 is 100-2)
                            running_sum <= running_sum + div_result[7:0];
                            current_term <= div_result[7:0];
                        end
                        else begin
                            // Divisor is above power of 10 (e.g. 102 is 100+2)
                            running_sum <= running_sum - div_result[7:0];
                            current_term <= div_result[7:0];
                        end
                    end
                end
                
                STATE_DONE: begin
                    quotient <= running_sum;
                    // Fixed remainder calculation to correctly account for difference
                    remainder <= dividend - (running_sum * (power10_value + difference));
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule
