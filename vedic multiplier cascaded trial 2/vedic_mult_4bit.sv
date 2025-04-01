module vedic_mult_4bit (
    input logic [3:0] a, b,
    output logic [7:0] out
);
    logic [3:0] w1, w2, w3, w4;
    logic [7:0] sum1, sum2;

    assign w1 = a[1:0] * b[1:0];
    assign w2 = a[1:0] * b[3:2];
    assign w3 = a[3:2] * b[1:0];
    assign w4 = a[3:2] * b[3:2];

    assign sum1 = {w4, 4'b0} + {2'b0, w2, 2'b0};
    assign sum2 = sum1 + {2'b0, w3, 2'b0};

    assign out = sum2 + {4'b0, w1};

endmodule
