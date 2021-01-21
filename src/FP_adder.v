module adder(
    input           clk,
    input           rst,
    input   [31:0]  a_in,
    input           a_stb,
    input   [31:0]  b_in,
    input           b_stb,
    input           z_ack,
    output          a_ack,
    output          b_ack,
    output  [31:0]  z_out,
    output          z_stb
);

endmodule
