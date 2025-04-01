module vedic_mult_4bit(
  input  logic [3:0] a, b,
  output logic [7:0] out
);
  // Internal signals for partial products
  logic [3:0] pp0, pp1, pp2, pp3;
  logic [5:0] s1, s2;
  logic [3:0] c;
  
  // Generate partial products
  assign pp0 = {a[3] & b[0], a[2] & b[0], a[1] & b[0], a[0] & b[0]};
  assign pp1 = {a[3] & b[1], a[2] & b[1], a[1] & b[1], a[0] & b[1]};
  assign pp2 = {a[3] & b[2], a[2] & b[2], a[1] & b[2], a[0] & b[2]};
  assign pp3 = {a[3] & b[3], a[2] & b[3], a[1] & b[3], a[0] & b[3]};
  
  // First bit of output is first partial product
  assign out[0] = pp0[0];
  
  // First stage addition
  assign s1[0] = pp0[1];
  assign s1[1] = pp0[2] ^ pp1[0];
  assign c[0] = pp0[2] & pp1[0];
  assign s1[2] = pp0[3] ^ pp1[1] ^ c[0];
  assign c[1] = (pp0[3] & pp1[1]) | (pp0[3] & c[0]) | (pp1[1] & c[0]);
  assign s1[3] = pp1[2] ^ pp2[0] ^ c[1];
  assign c[2] = (pp1[2] & pp2[0]) | (pp1[2] & c[1]) | (pp2[0] & c[1]);
  assign s1[4] = pp1[3] ^ pp2[1] ^ c[2];
  assign c[3] = (pp1[3] & pp2[1]) | (pp1[3] & c[2]) | (pp2[1] & c[2]);
  assign s1[5] = pp2[2] ^ pp3[0] ^ c[3];
  assign out[1] = s1[0];
  
  // Second stage addition using CLA
  CLA #(.WIDTH(4)) final_add(
    .a({1'b0, s1[5], s1[4], s1[3]}),
    .b({pp3[1], pp2[3], pp3[2], s1[2]}),
    .cin(1'b0),
    .sum(out[5:2]),
    .cout(out[6])
  );
  
  // Most significant bit
  assign out[7] = pp3[3] | out[6];
endmodule
