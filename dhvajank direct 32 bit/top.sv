module top #(
    parameter WIDTH = 16  // Bit width for dividend and divisor
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [WIDTH-1:0] dividend,
    input logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic done
);
    // Control signals
    typedef enum logic [2:0] {
        IDLE,
        INIT,
        DETERMINE_METHOD,
        COMPUTE,
        FINALIZE,
        DONE
    } state_t;
    
    state_t state, next_state;
    
    // Parameters for divisor analysis
    logic divisor_near_power10;
    logic [7:0] power10_value;
    logic signed [8:0] difference;
    
    // Internal signals
    logic [WIDTH-1:0] dividend_reg;
    logic [WIDTH-1:0] divisor_reg;
    logic [WIDTH-1:0] result_quotient;
    logic [WIDTH-1:0] result_remainder;
    logic [2:0] iteration_count;
    logic [2:0] max_iterations;
    
    // Instantiate the divisor analyzer
    divisor_analyzer #(.WIDTH(WIDTH)) u_divisor_analyzer (
        .divisor(divisor_reg),
        .power10_value(power10_value),
        .difference(difference),
        .is_near_power10(divisor_near_power10)
    );
    
    // Instantiate the computation module
    dhvajanka_compute #(.WIDTH(WIDTH)) u_dhvajanka_compute (
        .clk(clk),
        .rst_n(rst_n),
        .start(state == COMPUTE),
        .dividend(dividend_reg),
        .power10_value(power10_value),
        .difference(difference),
        .max_iterations(max_iterations),
        .quotient(result_quotient),
        .remainder(result_remainder),
        .done(compute_done)
    );
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = INIT;
            end
            
            INIT: begin
                next_state = DETERMINE_METHOD;
            end
            
            DETERMINE_METHOD: begin
                next_state = COMPUTE;
                // Could have additional states for different division methods
            end
            
            COMPUTE: begin
                if (compute_done)
                    next_state = FINALIZE;
            end
            
            FINALIZE: begin
                next_state = DONE;
            end
            
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // Data path
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dividend_reg <= '0;
            divisor_reg <= '0;
            quotient <= '0;
            remainder <= '0;
            done <= 1'b0;
            max_iterations <= 3'd3; // Default number of iterations
        end
        else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                end
                
                INIT: begin
                    dividend_reg <= dividend;
                    divisor_reg <= divisor;
                end
                
                DETERMINE_METHOD: begin
                    // Set max iterations based on desired precision
                    max_iterations <= divisor_near_power10 ? 3'd5 : 3'd3;
                end
                
                FINALIZE: begin
                    quotient <= result_quotient;
                    remainder <= result_remainder;
                end
                
                DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
    
endmodule
