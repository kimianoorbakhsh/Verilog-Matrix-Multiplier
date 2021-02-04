module writer
#(
    parameter n = 8,
    parameter n_len = $ceil($clog2(n))
)
(
    input      [31:0]                   value,
    input                               start,
    output  reg [n_len:0]                   j,
    output  reg [n_len:0]                   i,
    output  reg                         done
);

localparam s_idle = 2'b00;
localparam s_write = 2'b01;
localparam s_done = 2'b11;

reg [1:0] state   = s_idle; 
integer file;

initial begin
    wait (start);
    file = $fopen("sim_out.bin", "wb");
    for (i = 0 ; i < n ; i = i + 1) begin
        for (j = 0 ; j < n ; j = j + 1) begin
            #10 $fwrite(file, value);
        end
    end
    done = 1;
    $fclose(file);
end
endmodule