module sequential_matrix_multiplier
#(
    parameter m = 4
)
(
    input [31:0]    input_a,
    input [31:0]    input_b,
    input           clk,
    input           rst,
    output [$ceil($clog2(m))-1:0]   a_i,
    output [$ceil($clog2(m))-1:0]   a_j,
    output [$ceil($clog2(m))-1:0]   b_i,
    output [$ceil($clog2(m))-1:0]   b_j,
    output [31:0]   output_z,
);

endmodule
