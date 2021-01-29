module writer_testbench #(
    parameter n = 8   
)();

    reg [31:0]  matrix[0:n-1][0:n-1];

    integer i ;
    integer j ;
    reg val;
    reg write_start = 0;

    writer #(.n(n)) fileWriter (
        .value(matrix[r_i][r_j]),
        .start(write_start),
        .i(r_i),
        .j(r_j),
        .done(write_done)
)

    initial begin
        val = 0;
        for (i = 0 ; i < n ; i = i + 1) begin
            for (j = 0 ; j < n ; j = j + 1) begin
                matrix[i][j] = val;
                val = val + 1;
            end
        end

        write_start = 1;
        wait(write_done);
        $display("check the file");

    end

endmodule