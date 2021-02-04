module parallel_matrix_multiplier
#(
    parameter n = 10,
    parameter m = 4,
    parameter m_len = $ceil($clog2(m)),
    parameter n_len = $ceil($clog2(n))
)
(
    input                           clk,
    input                           rst,
    input                           start,
    input   [31:0]                  a_in,
    input   [n_len-1:0]             a_i,
    input   [n_len-1:0]             a_j,
    input                           a_we,
    input   [31:0]                  b_in,
    input   [n_len-1:0]             b_i,
    input   [n_len-1:0]             b_j,
    input                           b_we,
    input   [n_len-1:0]             z_i,
    input   [n_len-1:0]             z_j,
    output  [31:0]                  z_out,
    output                          done
); 

localparam num_of_matrices = $ceil(n / m);
localparam num_of_matrices_len = $ceil($clog2(num_of_matrices));

reg     [31:0]  A   [0:n-1][0:n-1];
reg     [31:0]  B   [0:n-1][0:n-1];
reg     [31:0]  R   [0:n-1][0:n-1];

wire    [-1:0]  done_signals;

assign z_out = R[z_i][z_j];
assign done = (~done_signals == 0); //(num_of_matrices**2){1'b1}); // potential bug

genvar i, j;
generate
    for (i = 0; i < num_of_matrices; i = i + 1) begin
        for (j = 0; j < num_of_matrices; j = j + 1) begin
            wire    [m_len-1:0] mul_a_i;
            wire    [n_len-1:0] mul_a_j;
            wire    [n_len-1:0] mul_b_i;
            wire    [m_len-1:0] mul_b_j;
            wire    [n_len-1:0] mul_z_i;
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
                .a_in(A[i * m + mul_a_i][j * m + mul_a_j]),
                .b_in(B[i * m + mul_b_i][j * m + mul_b_j]),
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
                    R[i * m + z_i][j * m + z_j] <= z_out;
                    z_ack <= 1;
                end
            end

            assign done_signals[i * num_of_matrices + j] = mul_done;
        end
    end
endgenerate

always @(posedge a_we) begin
    A[a_i][a_j] <= a_in;
end


always @(posedge b_we) begin
    B[b_i][b_j] <= b_in;
end




endmodule
