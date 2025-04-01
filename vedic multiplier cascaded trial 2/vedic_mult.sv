module vedic_mult #(parameter WIDTH = 8) (
    input logic [WIDTH-1:0] a, b,
    output logic [(2*WIDTH)-1:0] out
);
    localparam HALF_WIDTH = WIDTH / 2;

    if (WIDTH == 4) begin : base_case
        vedic_mult_4bit vm4 (.a(a), .b(b), .out(out));
    end else begin : recursive_case
        logic [WIDTH-1:0] w0, w1, w2, w3;
        logic [(2*WIDTH)-1:0] sum1, sum2;

        // Recursively instantiate smaller Vedic Multipliers
        vedic_mult #(HALF_WIDTH) v1 (.a(a[HALF_WIDTH-1:0]), .b(b[HALF_WIDTH-1:0]), .out(w0));
        vedic_mult #(HALF_WIDTH) v2 (.a(a[HALF_WIDTH-1:0]), .b(b[WIDTH-1:HALF_WIDTH]), .out(w1));
        vedic_mult #(HALF_WIDTH) v3 (.a(a[WIDTH-1:HALF_WIDTH]), .b(b[HALF_WIDTH-1:0]), .out(w2));
        vedic_mult #(HALF_WIDTH) v4 (.a(a[WIDTH-1:HALF_WIDTH]), .b(b[WIDTH-1:HALF_WIDTH]), .out(w3));

        // Corrected Zero-padding Syntax
        assign sum1 = {w3, {HALF_WIDTH{1'b0}}} + {{HALF_WIDTH{1'b0}}, w1, {HALF_WIDTH{1'b0}}};
        assign sum2 = sum1 + {{HALF_WIDTH{1'b0}}, w2, {HALF_WIDTH{1'b0}}};

        assign out = sum2 + {{WIDTH{1'b0}}, w0};
    end
endmodule
