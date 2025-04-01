module booth_encoder (
    input logic [2:0] booth_in,  // 3-bit Booth input (Y[i+1], Y[i], Y[i-1])
    output logic [1:0] op,       // Operation: 00 (0), 01 (+X), 10 (-X), 11 (+2X or -2X)
    output logic neg             // Indicates negative encoding
);
    always_comb begin
        case (booth_in)
            3'b000, 3'b111: {op, neg} = 3'b00_0; // 0
            3'b001, 3'b010: {op, neg} = 3'b01_0; // +X
            3'b101, 3'b110: {op, neg} = 3'b01_1; // -X
            3'b011:         {op, neg} = 3'b11_0; // +2X
            3'b100:         {op, neg} = 3'b11_1; // -2X
        endcase
    end
endmodule
