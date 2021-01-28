module parallel_matrix_multiplier
#(
    parameter n = 10,
    parameter m = 4
)
(
    input                           clk,
    input                           rst,
    input   [31:0]                  a_in,
    input   [$ceil($clog2(n))-1:0]  a_i,
    input   [$ceil($clog2(n))-1:0]  a_j,
    input                           a_we,
    input   [31:0]                  b_in,
    input   [$ceil($clog2(n))-1:0]  b_i,
    input   [$ceil($clog2(n))-1:0]  b_j,
    input                           b_we,
    input   [$ceil($clog2(n))-1:0]  z_i,
    input   [$ceil($clog2(n))-1:0]  z_j,
    output                          z_stb,
    output  [31:0]                  z_out,
    output                          done
);

endmodule
