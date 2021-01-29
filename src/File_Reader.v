module reader
#(
    parameter n = 8,
    parameter filenum = 1
)
(
    input                               value_ack,
    input                               start,
    input                               clk,
    output  reg [$ceil($clog2(n))-1:0]  i,
    output  reg [$ceil($clog2(n))-1:0]  j,
    output      [31:0]                  value,
    output  reg                         value_stb,
    output  reg                         done
);
reg [31:0]  matrix[0:n-1][0:n-1];

localparam s_idle = 2'b00;
localparam s_read = 2'b01;
localparam s_done = 2'b11;

reg [1:0] state   = s_idle; 
integer File_ID;

assign value = matrix[i][j];

initial begin
    case (filenum)
        1: File_ID = $fopen("input_1.bin", "rb");
        2: File_ID = $fopen("input_2.bin", "rb");
        default: $display("Invalid file num %d", filenum);
    endcase
    $fread(matrix, File_ID);
end

always @(posedge clk) begin
    case (state)
        s_idle : begin
            if (start) begin
                state <= s_read;
                done <= 0;
                i <= 0;
                j <= 0;
            end
        end
        s_read: begin
            if (value_ack) begin
                value_stb <= 0;
                if (j == n-1) begin
                    j <= 0;
                    if (i == n-1)
                        state <= s_done;
                    else
                        i <= i + 1;
                end
                else
                    j <= j + 1;
            end
            else
                value_stb <= 1;
        end
        s_done: begin
            done <= 1;
            state <= s_idle;
        end
        default: state <= s_idle;
    endcase
end

endmodule