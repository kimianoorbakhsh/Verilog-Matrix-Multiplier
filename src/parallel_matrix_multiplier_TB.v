module parallel_matrix_multiplier_TB();
    localparam          n       = 4;
    localparam          m       = 2;
    localparam          n_len   = $ceil($clog2(n));
    reg                 clk     = 0;
    reg                 rst     = 0;
    reg                 start   = 0;
    reg                 write_start = 0;
    wire    [n_len:0]   r_i;
    wire    [n_len:0]   r_j;
    wire    [31:0]      z_out;


    localparam clock_period = 10;
    always #clock_period clk = ~clk;

    parallel_matrix_multiplier #(
        .n(n),
        .m(m)
    ) MUL (
        .clk(clk),
        .rst(rst),
        .start(start),
        .z_i(r_i[n_len-1:0]),
        .z_j(r_j[n_len-1:0]),
        .z_out(z_out),
        .done(done)
    );

    integer file_id;

    writer #(.n(n)) out_writer (
        .value(z_out),
        .start(write_start),
        .i(r_i),
        .j(r_j),
        .done(write_done)
    );

    initial begin
        start = 1;
        #20 start = 0;
        wait (done);
        write_start = 1;
        wait (write_done);
        $stop;
    end

endmodule