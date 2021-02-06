`include "settings.h"
module row_col_multiplier
#(
    parameter n = `n,
    parameter m = `m,
    parameter m_len = $rtoi($ceil($clog2(m))),
    parameter n_len = $rtoi($ceil($clog2(n)))
)
(
    input                           clk,
    input                           rst,
    input                           start,
    input   [31:0]                  a_in,
    input   [31:0]                  b_in,
    input   [31:0]                  current_element,
    input                           z_ack,
    output  [m_len-1:0]             a_i,
    output  [n_len-1:0]             a_j,
    output  [n_len-1:0]             b_i,
    output  [m_len-1:0]             b_j,
    output  [31:0]                  z_out,
    output  [m_len-1:0]             z_i,
    output  [m_len-1:0]             z_j,
    output                          z_stb,
    output  reg                     done
);

parameter num_of_matrices = $rtoi($ceil(n / m));
parameter num_of_matrices_len = $rtoi($ceil($clog2(n / m)));

localparam s_idle = 2'b00;
localparam s_calc = 2'b01;
localparam s_done = 2'b10;

reg     [1:0]                       state;
reg     [num_of_matrices_len-1:0]   k;
reg                                 mul_start;
reg                                 mul_rst;

wire    [m_len-1:0]                 mul_a_j;
wire    [m_len-1:0]                 mul_b_i;

assign  a_j = k * m + mul_a_j;
assign  b_i = k * m + mul_b_i;

sequential_matrix_multiplier #(
    .m(m)
) MUL (
    .clk(clk),
    .rst(mul_rst),
    .start(mul_start),
    .a_in(a_in),
    .b_in(b_in),
    .current_element(current_element),
    .z_ack(z_ack),
    .a_i(a_i),
    .a_j(mul_a_j),
    .b_i(mul_b_i),
    .b_j(b_j),
    .z_out(z_out),
    .z_i(z_i),
    .z_j(z_j),
    .z_stb(z_stb),
    .done(mul_done)
);

always @(posedge clk or posedge rst) begin

    if (rst) begin
        state <= s_idle;
        done <= 0;
        k <= 0;
        mul_start <= 0;
        mul_rst <= 1;
    end
    else begin

        casex(state)

            s_idle: begin
                if (start) begin
                    state <= s_calc;
                    done <= 0;
                    k <= 0;
                    mul_start <= 0;
                    mul_rst <= 1;
                end
            end
            s_calc: begin
                mul_start <= 1;
                mul_rst <= 0;
                if (mul_done) begin
                    mul_start <= 0;
                    mul_rst <= 1;
                    if (k == num_of_matrices - 1)
                        state <= s_done;
                    else
                        k <= k + 1;
                end
            end
            s_done: begin
                done <= 1;
                state <= s_idle;
            end

            default: state <= s_idle;
        endcase

    end

end

endmodule