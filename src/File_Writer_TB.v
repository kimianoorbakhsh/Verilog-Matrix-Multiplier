module writer_testbench #(
    parameter n = 8   
)();

    reg [31:0]  matrix[0:n-1][0:n-1];

    integer i ;
    integer j ;
    integer val;

    writer fileWriter
#(
    .n(n)
)
(
    input      [31:0]                   value,
    input      tr                         start,
    output  reg [$ceil($clog2(n))-1:0]  i,
    output  reg [$ceil($clog2(n))-1:0]  j,
    output  reg                         done
)

    initial begin
        val = 0;
        for (i = 0 ; i < n ; i = i + 1) begin
            for (j = 0 ; j < n ; j = j + 1) begin
                matrix[i][j] = val;
                val = val + 1;
            end
        end


    end

endmodule