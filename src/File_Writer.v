`timescale 1ns/1ns 

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
            $display("writing result[%d][%d] = %b", i, j, value);
            #10 $fwrite(file, "%c%c%c%c", value[31:24], value[23:16], value[15:8], value[7:0]);
        end
    end
    done = 1;
    $fclose(file);
end
endmodule