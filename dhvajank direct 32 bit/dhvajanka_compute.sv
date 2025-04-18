
module dhvajanka_compute #(
    parameter WIDTH = 16
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [WIDTH-1:0] dividend,
    input logic [7:0] power10_value,
    input logic signed [8:0] difference,
    input logic [2:0] max_iterations,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic done
);
    // Internal registers
    typedef enum logic [1:0] {
        IDLE,
        CALCULATING,
        DONE
    } calc_state_t;
    
    calc_state_t calc_state, next_calc_state;
    
    logic [WIDTH-1:0] current_term;
    logic [WIDTH-1:0] running_sum;
    logic [2:0] iteration;
    logic [WIDTH+16-1:0] mult_result; // Extended precision for multiplication
    logic signed [8:0] abs_diff;
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            calc_state <= IDLE;
        else
            calc_state <= next_calc_state;
    end
    
    always_comb begin
        next_calc_state = calc_state;
        
        case (calc_state)
            IDLE: begin
                if (start)
                    next_calc_state = CALCULATING;
            end
            
            CALCULATING: begin
                if (iteration >= max_iterations)
                    next_calc_state = DONE;
            end
            
            DONE: begin
                next_calc_state = IDLE;
            end
        endcase
    end
    
    // Get absolute value of difference
    assign abs_diff = (difference < 0) ? -difference : difference;
    
    // Main computation logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_term <= '0;
            running_sum <= '0;
            iteration <= '0;
            quotient <= '0;
            remainder <= '0;
            done <= 1'b0;
            mult_result <= '0;
        end
        else begin
            case (calc_state)
                IDLE: begin
                    if (start) begin
                        // Initialize with first step
                        iteration <= '0;
                        done <= 1'b0;
                        
                        // First step: dividend / power10
                        // For example, if power10 = 100, shift right by 2 decimal places
                        if (power10_value == 8'd10)
                            current_term <= dividend / 10;
                        else if (power10_value == 8'd100)
                            current_term <= dividend / 100;
                        else if (power10_value == 8'd1000)
                            current_term <= dividend / 1000;
                        else
                            current_term <= dividend / power10_value;
                        
                        running_sum <= dividend / power10_value;
                    end
                end
                
                CALCULATING: begin
                    iteration <= iteration + 1'b1;
                    
                    // Perform operation based on whether divisor is above or below power of 10
                    if (difference > 0) begin
                        // Divisor is below power of 10 (e.g. 98 is 100-2)
                        // Multiply current term by difference/power10 (e,g. 2/100)
                        mult_result <= (current_term * abs_diff);
                        current_term <= (current_term * abs_diff) / power10_value;
                        running_sum <= running_sum + (current_term * abs_diff) / power10_value;
                    end
                    else begin
                        // Divisor is above power of 10 (e.g. 102 is 100+2)
                        // Multiply current term by difference/power10 (e.g. 2/100) and subtract
                        mult_result <= (current_term * abs_diff);
                        current_term <= (current_term * abs_diff) / power10_value;
                        running_sum <= running_sum - (current_term * abs_diff) / power10_value;
                    end
                end
                
                DONE: begin
                    quotient <= running_sum;
                    // Calculate remainder: dividend - quotient * divisor
                    // This is a simplified approach; in practice you'd want more precision
                    // remainder <= dividend - (running_sum * (power10_value - difference));
                    remainder <= dividend - (running_sum * (power10_value - difference));
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule
