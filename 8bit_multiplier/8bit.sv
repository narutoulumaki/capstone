module vedic_mult_8bit (
    input logic [7:0] a, b,
    output logic [15:0] out
);
    // Individual bit-by-bit multiplication results
    logic [7:0] r0, r1, r2, r3, r4, r5, r6, r7;
    
    // Each row represents multiplication of all bits of 'a' with one bit of 'b'
    assign r0[0] = a[0] & b[0];
    assign r0[1] = a[1] & b[0];
    assign r0[2] = a[2] & b[0];
    assign r0[3] = a[3] & b[0];
    assign r0[4] = a[4] & b[0];
    assign r0[5] = a[5] & b[0];
    assign r0[6] = a[6] & b[0];
    assign r0[7] = a[7] & b[0];
    
    assign r1[0] = a[0] & b[1];
    assign r1[1] = a[1] & b[1];
    assign r1[2] = a[2] & b[1];
    assign r1[3] = a[3] & b[1];
    assign r1[4] = a[4] & b[1];
    assign r1[5] = a[5] & b[1];
    assign r1[6] = a[6] & b[1];
    assign r1[7] = a[7] & b[1];
    
    assign r2[0] = a[0] & b[2];
    assign r2[1] = a[1] & b[2];
    assign r2[2] = a[2] & b[2];
    assign r2[3] = a[3] & b[2];
    assign r2[4] = a[4] & b[2];
    assign r2[5] = a[5] & b[2];
    assign r2[6] = a[6] & b[2];
    assign r2[7] = a[7] & b[2];
    
    assign r3[0] = a[0] & b[3];
    assign r3[1] = a[1] & b[3];
    assign r3[2] = a[2] & b[3];
    assign r3[3] = a[3] & b[3];
    assign r3[4] = a[4] & b[3];
    assign r3[5] = a[5] & b[3];
    assign r3[6] = a[6] & b[3];
    assign r3[7] = a[7] & b[3];
    
    assign r4[0] = a[0] & b[4];
    assign r4[1] = a[1] & b[4];
    assign r4[2] = a[2] & b[4];
    assign r4[3] = a[3] & b[4];
    assign r4[4] = a[4] & b[4];
    assign r4[5] = a[5] & b[4];
    assign r4[6] = a[6] & b[4];
    assign r4[7] = a[7] & b[4];
    
    assign r5[0] = a[0] & b[5];
    assign r5[1] = a[1] & b[5];
    assign r5[2] = a[2] & b[5];
    assign r5[3] = a[3] & b[5];
    assign r5[4] = a[4] & b[5];
    assign r5[5] = a[5] & b[5];
    assign r5[6] = a[6] & b[5];
    assign r5[7] = a[7] & b[5];
    
    assign r6[0] = a[0] & b[6];
    assign r6[1] = a[1] & b[6];
    assign r6[2] = a[2] & b[6];
    assign r6[3] = a[3] & b[6];
    assign r6[4] = a[4] & b[6];
    assign r6[5] = a[5] & b[6];
    assign r6[6] = a[6] & b[6];
    assign r6[7] = a[7] & b[6];
    
    assign r7[0] = a[0] & b[7];
    assign r7[1] = a[1] & b[7];
    assign r7[2] = a[2] & b[7];
    assign r7[3] = a[3] & b[7];
    assign r7[4] = a[4] & b[7];
    assign r7[5] = a[5] & b[7];
    assign r7[6] = a[6] & b[7];
    assign r7[7] = a[7] & b[7];
    
    // Shift each row according to position and add to form final product
    logic [15:0] s0, s1, s2, s3, s4, s5, s6, s7;
    
    // Align based on bit position
    assign s0 = {8'b0, r0};
    assign s1 = {7'b0, r1, 1'b0};
    assign s2 = {6'b0, r2, 2'b0};
    assign s3 = {5'b0, r3, 3'b0};
    assign s4 = {4'b0, r4, 4'b0};
    assign s5 = {3'b0, r5, 5'b0};
    assign s6 = {2'b0, r6, 6'b0};
    assign s7 = {1'b0, r7, 7'b0};
    
    // Add all partial products
    assign out = s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7;
endmodule
