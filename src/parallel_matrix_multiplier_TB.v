module parallel_matrix_multiplier_TB();
    localparam          n       = 4;
    localparam          m       = 2;
    localparam          n_len   = $ceil($clog2(n));
    localparam          m_len   = $ceil($clog2(m));
    reg                 clk     = 0;
    reg                 rst     = 0;
    reg                 start   = 0;
    reg     [31:0]      A   [0:n-1][0:n-1];
    reg     [31:0]      B   [0:n-1][0:n-1];
    reg     [n_len-1:0] i;
    reg     [n_len-1:0] j;
    reg     [n_len-1:0] we;
    reg                 write_start = 0;
    wire    [n_len:0]   r_i;
    wire    [n_len:0]   r_j;
    wire    [31:0]      z_out;


    localparam clock_period = 10;
    always #clock_period clk = ~clk;

    parallel_matrix_multiplier MUL(
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_in(A[i][j]),
        .a_i(i),
        .a_j(j),
        .a_we(we),
        .b_in(B[i][j]),
        .b_i(i),
        .b_j(j),
        .b_we(we),
        .z_i(r_i[n_len-1:0]),
        .z_j(r_i[n_len-1:0]),
        .z_out(z_out),
        .done(done)
    );

    integer file_id;

    writer #(.n(m)) out_writer (
        .value(R[r_i][r_j]),
        .start(write_start),
        .i(r_i),
        .j(r_j),
        .done(write_done)
    );

    initial begin
        file_id = $fopen("data/square_input_a.bin", "rb");
        $fread(A, file_id);
        $fclose(file_id);
        file_id = $fopen("data/square_input_b.bin", "rb");
        $fread(B, file_id);
        $fclose(file_id);

        // Writing data to parallel multiplier
        for (i = 0; i < n; i = i + 1) begin
            for (j = 0; j < n; j = j + 1) begin
                we = 1;
                #10 we = 0;
            end
        end

        start = 1;
        wait (done);
        write_start = 1;
        wait (write_done);
        $stop;
    end

endmodule