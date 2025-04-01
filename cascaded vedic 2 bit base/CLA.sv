module CLA #(
  parameter WIDTH = 4
)(
  input  logic [WIDTH-1:0] a, b,
  input  logic cin,
  output logic [WIDTH-1:0] sum,
  output logic cout
);
  generate
    if (WIDTH == 4) begin : cla4
      // Direct implementation for 4-bit CLA
      logic [3:0] gen, prop;
      logic [2:0] c;
      
      // Generate and propagate
      assign gen = a & b;
      assign prop = a ^ b;
      
      // Carry calculation
      assign c[0] = gen[0] | (prop[0] & cin);
      assign c[1] = gen[1] | (prop[1] & c[0]);
      assign c[2] = gen[2] | (prop[2] & c[1]);
      assign cout = gen[3] | (prop[3] & c[2]);
      
      // Sum calculation
      assign sum = prop ^ {c[2:0], cin};
    end else begin : cla_recursive
      // Recursive implementation for wider CLAs
      logic c_int;
      
      CLA #(.WIDTH(WIDTH/2)) cla_low(
        .a(a[WIDTH/2-1:0]),
        .b(b[WIDTH/2-1:0]),
        .cin(cin),
        .sum(sum[WIDTH/2-1:0]),
        .cout(c_int)
      );
      
      CLA #(.WIDTH(WIDTH/2)) cla_high(
        .a(a[WIDTH-1:WIDTH/2]),
        .b(b[WIDTH-1:WIDTH/2]),
        .cin(c_int),
        .sum(sum[WIDTH-1:WIDTH/2]),
        .cout(cout)
      );
    end
  endgenerate
endmodule
