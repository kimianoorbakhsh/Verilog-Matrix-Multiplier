module writer
#(
    parameter n = 8
)
(

    // input                               clk,
    // input                               value_stb,
    input      [31:0]                   value,
    input                               start,
    output  reg [$ceil($clog2(n))-1:0]  i,
    output  reg [$ceil($clog2(n))-1:0]  j,
    // output  reg                         value_ack,
    output  reg                         done
)

localparam s_idle = 2'b00;
localparam s_write = 2'b01;
localparam s_done = 2'b11;

reg [1:0] state   = s_idle; 

initial begin
    wait (start);

    file = $fopen("sim_out.bin", "ab");

    for (i = 0 ; i < n ; i = i + 1) begin
        for (j = 0 ; j < n ; j = j + 1) begin
            #10 $fwrite(file, "%b", value);
        end
    end
    done = 1;
    $fclose(file);
end

/*
always @ (posedge clk) begin
     case (state)
        s_idle : begin
            if (start) begin
                state <= s_write;
                done <= 0;
                i <= 0;
                j <= 0;
            end
        end
        s_write: begin
            if (value_stb) begin
                value_ack <= 0;
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
                value_ack <= 1;
        end
        s_done: begin
            done <= 1;
            state <= s_idle;
        end
        default: state <= s_idle;
    endcase
end
*/


endmodule