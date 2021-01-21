module sequential_matrix_multiplier
#(
    parameter m = 4
)
(
    input                           clk,
    input                           rst,
    input   [31:0]                  a_in,
    input   [31:0]                  b_in,
    output  [$ceil($clog2(m))-1:0]  a_i,
    output  [$ceil($clog2(m))-1:0]  a_j,
    output  [$ceil($clog2(m))-1:0]  b_i,
    output  [$ceil($clog2(m))-1:0]  b_j,
    output  [31:0]                  z_out,
    output  [$ceil($clog2(m))-1:0]  z_i,
    output  [$ceil($clog2(m))-1:0]  z_j,
    output                          z_stb
);

endmodule
