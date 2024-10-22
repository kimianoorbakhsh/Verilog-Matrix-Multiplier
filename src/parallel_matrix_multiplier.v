// `include "settings.h"
`timescale 1 ns / 1 ns

module parallel_matrix_multiplier
#(
    parameter n = 4,
    parameter m = 2,
    parameter m_len = $rtoi($ceil($clog2(m))),
    parameter n_len = $rtoi($ceil($clog2(n)))
)
(
    input                           clk,
    input                           rst,
    input                           start,
    input   [n_len-1:0]             z_i,
    input   [n_len-1:0]             z_j,
    output  [31:0]                  z_out,
    output                          done
);

parameter num_of_matrices = $rtoi($ceil(n / m));
parameter num_of_matrices_len = $rtoi($ceil($clog2(n / m)));

reg     [31:0]  A   [0:n-1][0:n-1];
reg     [31:0]  B   [0:n-1][0:n-1];
reg     [31:0]  R   [0:n-1][0:n-1];

localparam l = num_of_matrices**2;
wire    [l-1:0]  done_signals;
assign done = (done_signals == {l{1'b1}});

assign z_out = R[z_i][z_j];

genvar i, j;
generate
    for (i = 0; i < num_of_matrices; i = i + 1) begin
        for (j = 0; j < num_of_matrices; j = j + 1) begin
            wire    [m_len-1:0] mul_a_i;
            wire    [n_len-1:0] mul_a_j;
            wire    [n_len-1:0] mul_b_i;
            wire    [m_len-1:0] mul_b_j;
            wire    [m_len-1:0] mul_z_i;
            wire    [m_len-1:0] mul_z_j;
            wire    [31:0]      mul_z_out;
            reg                 z_ack;

            row_col_multiplier #(
                .n(n),
                .m(m)
            ) MUL (
                .clk(clk),
                .rst(rst),
                .start(start),
                .a_in(A[i * m + mul_a_i][mul_a_j]),
                .b_in(B[mul_b_i][j * m + mul_b_j]),
                .current_element(R[i * m + mul_z_i][j * m + mul_z_j]),
                .z_ack(z_ack),
                .a_i(mul_a_i),
                .a_j(mul_a_j),
                .b_i(mul_b_i),
                .b_j(mul_b_j),
                .z_out(mul_z_out),
                .z_i(mul_z_i),
                .z_j(mul_z_j),
                .z_stb(z_stb),
                .done(mul_done)
            );

            always @(posedge clk) begin
                z_ack <= 0;
                if (z_stb) begin
                    R[i * m + mul_z_i][j * m + mul_z_j] <= mul_z_out;
                    $display("[%1d, %1d] Writing R[%1d][%1d] = %b", i, j, i * m + mul_z_i, j * m + mul_z_j, mul_z_out);
                    z_ack <= 1;
                end
            end

            // initial begin
            //     $display("row_col n: %1d, m: %1d - seq m: %1d", MUL.n, MUL.m, MUL.MUL.m);
            //     $monitor("[%1d, %1d] Reading A[%1d][%1d]: %b, B[%1d][%1d]: %b", i, j, i * m + mul_a_i, mul_a_j, A[i * m + mul_a_i][mul_a_j], mul_b_i, j * m + mul_b_j, B[mul_b_i][j * m + mul_b_j]);
            // end
            assign done_signals[i * num_of_matrices + j] = mul_done;
        end
    end
endgenerate


integer file_id, r_i, r_j;
initial begin
    file_id = $fopen("data/square_input_a.bin", "rb");
    $fread(A, file_id);
    $fclose(file_id);
    file_id = $fopen("data/square_input_b.bin", "rb");
    $fread(B, file_id);
    $fclose(file_id);

    $display("parallel n: %1d, m: %1d", n, m);

    for (r_i = 0; r_i < n; r_i = r_i + 1) begin
        for (r_j = 0; r_j < n; r_j = r_j + 1) begin
            R[r_i][r_j] = 0;
            if (^A[r_i][r_j] === 1'bx) begin
                A[r_i][r_j] = 0;
            end
            if (^B[r_i][r_j] === 1'bx) begin
                B[r_i][r_j] = 0;
            end
            $display("A[%1d][%1d] = %b", r_i, r_j, A[r_i][r_j]);
            $display("B[%1d][%1d] = %b", r_i, r_j, B[r_i][r_j]);
        end
    end
end

endmodule
