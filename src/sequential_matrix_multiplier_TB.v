module sequential_matrix_multiplier_TB();
    localparam m = 4;
    reg         clk = 0;
    reg         rst = 1;
    reg         start = 0;
    reg         z_ack = 0;
    reg [31:0]  A   [0:m-1][0:m-1];
    reg [31:0]  B   [0:m-1][0:m-1];
    reg [31:0]  R   [0:m-1][0:m-1];
    reg write_start = 0;

    always #10 clk = ~clk;

    sequential_matrix_multiplier MUL(
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_in(A[a_i][a_j]),
        .b_in(B[b_i][b_j]),
        .z_ack(z_ack),
        .a_i(a_i),
        .a_j(a_j),
        .b_i(b_i),
        .b_j(b_j),
        .z_out(z_out),
        .z_i(z_i),
        .z_j(z_j),
        .z_stb(z_stb),
        .done(done)
    );

    integer file_id;

    writer #(.n(m)) out_writer (
        .value(R[r_i][r_j]),
        .start(write_start),
        .i(r_i),
        .j(r_j),
        .done(write_done)
    )

    initial begin
        file_id = $fopen("../data/seq_input_a.bin", "rb");
        $fread(A, file_id);
        $fclose(file_id);
        file_id = $fopen("../data/seq_input_b.bin", "rb");
        $fread(B, file_id);
        $fclose(file_id);

        start = 1;

        wait (done);
        write_start = 1;
        wait (write_done);
        $stop;
    end

    always @ (posedge clk) begin
        z_ack <= 0;
        if (z_stb) begin
            R[z_i][z_j] <= z_out;
            z_ack <= 1;
        end
    end

endmodule
