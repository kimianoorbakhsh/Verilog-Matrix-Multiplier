module sequential_matrix_multiplier
#(
    parameter m = 4
)
(
    input_a,
    input_b,
    input_a_stb,
    input_b_stb,
    output_z_ack,
    clk,
    rst,
    output_z,
    output_z_stb,
    input_a_ack,
    input_b_ack
);

  input     clk;
  input     rst;

  input     [31:0] input_a  [m-1:0][m-1:0];
  input     input_a_stb;
  output    input_a_ack;

  input     [31:0] input_b  [m-1:0][m-1:0];
  input     input_b_stb;
  output    input_b_ack;

  output    [31:0] output_z [m-1:0][m-1:0];
  output    output_z_stb;
  input     output_z_ack;

endmodule
