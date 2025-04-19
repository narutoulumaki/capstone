module dhvajanka_compute_16bit (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [15:0] dividend,
    input logic [15:0] divisor,       // Added actual divisor for correct remainder calc
    input logic [7:0] power10_value,
    input logic signed [8:0] difference,
    input logic [2:0] max_iterations,
    output logic [15:0] quotient,
    output logic [15:0] remainder,
    output logic done
);
    // Internal registers
    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_CALCULATING,
        STATE_DONE
    } calc_state_t;
    
    calc_state_t curr_state, next_state;
    
    logic [15:0] current_term;
    logic [15:0] running_sum;
    logic [2:0] iteration;
    logic [31:0] mult_result;   // Extended precision for multiplication
    logic [31:0] temp_result;   // Temporary result with more precision
    logic signed [8:0] abs_diff;
    
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
    
    // Main computation logic - with improved precision handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_term <= '0;
            running_sum <= '0;
            iteration <= '0;
            quotient <= '0;
            remainder <= '0;
            done <= 1'b0;
            mult_result <= '0;
            temp_result <= '0;
        end
        else begin
            case (curr_state)
                STATE_IDLE: begin
                    if (start) begin
                        // Initialize for calculation
                        iteration <= '0;
                        done <= 1'b0;
                        
                        // First step: dividend / power10
                        // Scale up for better precision
                        if (power10_value == 8'd10) begin
                            // Scale up by 1000 (10³) for fixed-point math
                            current_term <= (dividend * 1000) / 10;
                            running_sum <= dividend / 10;
                        end
                        else if (power10_value == 8'd100) begin
                            current_term <= (dividend * 1000) / 100;
                            running_sum <= dividend / 100;
                        end
                        else if (power10_value == 8'd1000) begin
                            current_term <= (dividend * 1000) / 1000;
                            running_sum <= dividend / 1000;
                        end
                        else begin
                            current_term <= (dividend * 1000) / power10_value;
                            running_sum <= dividend / power10_value;
                        end
                    end
                end
                
                STATE_CALCULATING: begin
                    iteration <= iteration + 1'b1;
                    
                    // Perform operation based on whether divisor is above or below power of 10
                    if (difference > 0) begin
                        // Divisor is below power of 10 (e.g. 98 is 100-2)
                        // current_term is already scaled by 1000
                        mult_result <= (current_term * abs_diff);
                        
                        // Divide by power10_value, maintaining scale
                        // We're dividing a value scaled by 1000, so result is also scaled
                        temp_result <= mult_result / power10_value;
                        
                        // Update scaled term for next iteration
                        current_term <= temp_result;
                        
                        // For the running sum, we need to convert back to normal scale
                        // by dividing by 1000 (or right-shifting by 10 bits is close enough)
                        if (iteration == 3'd0) begin
                            // First time setup - happens after iteration is incremented to 1
                            running_sum <= running_sum;
                        end else begin
                            running_sum <= running_sum + (temp_result / 1000);
                        end
                    end
                    else begin
                        // Divisor is above power of 10 (e.g. 102 is 100+2)
                        mult_result <= (current_term * abs_diff);
                        temp_result <= mult_result / power10_value;
                        current_term <= temp_result;
                        
                        if (iteration == 3'd0) begin
                            running_sum <= running_sum;
                        end else begin
                            running_sum <= running_sum - (temp_result / 1000);
                        end
                    end
                end
                
                STATE_DONE: begin
                    quotient <= running_sum;
                    // Correct remainder calculation using the actual divisor
                    remainder <= dividend - (running_sum * divisor);
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule
