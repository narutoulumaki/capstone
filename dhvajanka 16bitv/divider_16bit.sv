module cascaded_vedic_divider_16bit #(
    parameter WIDTH = 32
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
    // Constants and local params
    localparam HALF_WIDTH = WIDTH/2;  // 16 bits
    
    // Control signals
    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_SETUP,
        STATE_DIVIDE_UPPER,
        STATE_COMPUTE_MIDDLE,
        STATE_DIVIDE_LOWER,
        STATE_COMBINE,
        STATE_DONE
    } state_t;
    
    state_t state, next_state;
    
    // Internal signals for cascaded division
    logic [HALF_WIDTH-1:0] upper_dividend;
    logic [HALF_WIDTH-1:0] lower_dividend;
    logic [HALF_WIDTH-1:0] divisor_half;
    
    logic [HALF_WIDTH-1:0] upper_quotient;
    logic [HALF_WIDTH-1:0] upper_remainder;
    logic [HALF_WIDTH-1:0] middle_dividend;
    logic [HALF_WIDTH-1:0] middle_quotient;
    logic [HALF_WIDTH-1:0] middle_remainder;
    logic [HALF_WIDTH-1:0] lower_quotient;
    logic [HALF_WIDTH-1:0] lower_remainder;
    
    logic upper_start, middle_start, lower_start;
    logic upper_done, middle_done, lower_done;
    
    // Instantiate two 16-bit basic dividers
    vedic_divider_16bit u_upper_divider (
        .clk(clk),
        .rst_n(rst_n),
        .start(upper_start),
        .dividend(upper_dividend),
        .divisor(divisor_half),
        .quotient(upper_quotient),
        .remainder(upper_remainder),
        .done(upper_done)
    );
    
    vedic_divider_16bit u_middle_divider (
        .clk(clk),
        .rst_n(rst_n),
        .start(middle_start),
        .dividend(middle_dividend),
        .divisor(divisor_half),
        .quotient(middle_quotient),
        .remainder(middle_remainder),
        .done(middle_done)
    );
    
    vedic_divider_16bit u_lower_divider (
        .clk(clk),
        .rst_n(rst_n),
        .start(lower_start),
        .dividend(lower_dividend),
        .divisor(divisor_half),
        .quotient(lower_quotient),
        .remainder(lower_remainder),
        .done(lower_done)
    );
    
    // State machine - sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= STATE_IDLE;
        else
            state <= next_state;
    end
    
    // Next state logic - combinational logic
    always_comb begin
        next_state = state;
        
        case (state)
            STATE_IDLE: begin
                if (start)
                    next_state = STATE_SETUP;
            end
            
            STATE_SETUP: begin
                next_state = STATE_DIVIDE_UPPER;
            end
            
            STATE_DIVIDE_UPPER: begin
                if (upper_done)
                    next_state = STATE_COMPUTE_MIDDLE;
            end
            
            STATE_COMPUTE_MIDDLE: begin
                next_state = STATE_DIVIDE_LOWER;
            end
            
            STATE_DIVIDE_LOWER: begin
                if (lower_done)
                    next_state = STATE_COMBINE;
            end
            
            STATE_COMBINE: begin
                next_state = STATE_DONE;
            end
            
            STATE_DONE: begin
                next_state = STATE_IDLE;
            end
        endcase
    end
    
    // Control signals - combinational logic
    always_comb begin
        upper_start = 0;
        middle_start = 0;
        lower_start = 0;
        
        case (state)
            STATE_DIVIDE_UPPER: upper_start = 1;
            STATE_DIVIDE_LOWER: lower_start = 1;
            default: begin
                upper_start = 0;
                lower_start = 0;
            end
        endcase
    end
    
    // Datapath logic - sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            upper_dividend <= '0;
            lower_dividend <= '0;
            middle_dividend <= '0;
            divisor_half <= '0;
            quotient <= '0;
            remainder <= '0;
            done <= 1'b0;
        end
        else begin
            case (state)
                STATE_IDLE: begin
                    done <= 1'b0;
                end
                
                STATE_SETUP: begin
                    // Split the 32-bit dividend into two 16-bit parts
                    upper_dividend <= dividend[WIDTH-1:HALF_WIDTH];
                    lower_dividend <= dividend[HALF_WIDTH-1:0];
                    // For simplicity, we'll use lower half of divisor
                    // In a real implementation, you'd need more logic to handle different divisor sizes
                    divisor_half <= divisor[HALF_WIDTH-1:0];
                end
                
                STATE_COMPUTE_MIDDLE: begin
                    // Compute middle dividend based on upper remainder
                    middle_dividend <= {upper_remainder, 8'h0};
                end
                
                STATE_COMBINE: begin
                    // Combine results from both divisions
                    quotient <= {upper_quotient, lower_quotient};
                    remainder <= lower_remainder;
                end
                
                STATE_DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule
