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
    output  [31:0]                  z_out
);

localparam seq_num = $ceil(n / m);
localparam index_width = $ceil($clog2(m));

reg [31:0]  A       [0:n-1][0:n-1];
reg [31:0]  B       [0:n-1][0:n-1];
reg [31:0]  seq_res [0:seq_num-1][0:seq_num-1][0:m-1][0:m-1];

genvar i, j;
generate
    for (i = 0; i < seq_num; i = i + 1) begin
        for (j = 0; j < seq_num; j = j + 1) begin
            sequential_matrix_multiplier SEQ (
                .clk(clk),
                .rst(rst),
                .a_in(A[i * m + a_i][j * m + a_j]),
                .b_in(B[i * m + b_i][j * m + b_j]),
                .a_i(a_i),
                .a_j(a_j),
                .b_i(b_i),
                .b_j(b_j),
                .z_out(seq_res[i][j][z_i][z_j]),
                .z_i(z_i),
                .z_j(z_j),
                .z_stb(z_stb)
            );
        end
    end
endgenerate

endmodule
