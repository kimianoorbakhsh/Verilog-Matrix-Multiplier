`timescale 1 ns / 1 ns

module row_col_multiplier_TB #(
    parameter n = 8,
    parameter m = 4,
    parameter m_len = $ceil($clog2(m)),
    parameter n_len = $ceil($clog2(n))
)();
reg         clk = 0;
reg         rst = 0;
reg         start = 0;
reg [31:0]  A   [0:m-1][0:n-1];
reg [31:0]  B   [0:n-1][0:m-1];
reg [31:0]  R   [0:m-1][0:m-1];
reg         z_ack;
reg write_start = 0;

wire    [m_len-1:0] a_i;
wire    [n_len-1:0] a_j;
wire    [n_len-1:0] b_i;
wire    [m_len-1:0] b_j;
wire    [m_len-1:0] z_i;
wire    [m_len-1:0] z_j;
wire    [m_len:0]   r_i;
wire    [m_len:0]   r_j;
wire    [31:0]      z_out;


row_col_multiplier #(.n(n), .m(m)) MUL (
.clk(                   clk         ),
.rst(                   rst         ),
.start(                 start       ),
.a_in(                  A[a_i][a_j] ),
.b_in(                  B[b_i][b_j] ),
.current_element(       R[z_i][z_j] ),
.z_ack(                 z_ack       ),
.a_i(                   a_i         ),
.a_j(                   a_j         ),
.b_i(                   b_i         ),
.b_j(                   b_j         ),
.z_out(                 z_out       ),
.z_i(                   z_i         ),
.z_j(                   z_j         ),
.z_stb(                 z_stb       ),
.done(                  done)
);

writer #(.n(m)) out_writer (
    .value(R[r_i][r_j]),
    .start(write_start),
    .i(r_i),
    .j(r_j),
    .done(writer_done)
);

localparam clock_period = 10;
always #clock_period clk = ~clk;

integer file_id;
integer i, j;
initial begin

    for (i = 0; i < m; i = i + 1) begin
        for (j = 0; j < m; j = j + 1) begin
            R[i][j] = 0; 
        end
    end

    file_id = $fopen("data/row_input.bin", "rb");
    $fread(A, file_id);
    $fclose(file_id);
    file_id = $fopen("data/col_input.bin", "rb");
    $fread(B, file_id);
    $fclose(file_id);

    start = 1;
    wait (done);
    write_start = 1;
    wait (writer_done);
    $stop;
end
 
 
always @ (posedge clk) begin
        z_ack <= 0;
        if (z_stb) begin
            $display("R[%1d][%1d] = %b", z_i, z_j, z_out);
            R[z_i][z_j] <= z_out;
            z_ack <= 1;
        end
end
    
endmodule