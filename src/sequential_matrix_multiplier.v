// `include "settings.h"
`timescale 1 ns / 1 ns

module sequential_matrix_multiplier
#(
    parameter m = 4,
    parameter m_len =$rtoi($ceil($clog2(m)))
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
    output  [m_len-1:0]             a_j,
    output  [m_len-1:0]             b_i,
    output  [m_len-1:0]             b_j,
    output  reg [31:0]              z_out,
    output  [m_len-1:0]             z_j,
    output  [m_len-1:0]             z_i,
    output  reg                     z_stb,
    output  reg                     done
);

localparam s_idle               =       3'b000;
localparam s_a_ack_mul          =       3'b001;
localparam s_b_ack_mul          =       3'b010;
localparam s_wait_mul           =       3'b011;
localparam s_b_ack_add          =       3'b100;
localparam s_wait_add           =       3'b101; 
localparam s_done               =       3'b110;
localparam s_reset              =       3'b111;

reg [2:0]       state;
reg [m_len-1:0] i;
reg [m_len-1:0] j;
reg [m_len-1:0] k;  // a[i,k] * b [k,j]
reg             mul_input_a_stb;
reg             mul_input_b_stb;
reg             mul_output_z_ack;
reg             add_input_a_stb;
reg             add_input_b_stb;
reg             add_output_z_ack;
reg             reset;
wire    [31:0]  mul_result;
wire    [31:0]  add_result;

assign a_i = i;
assign a_j = k;
assign b_i = k;
assign b_j = j;
assign z_i = i;
assign z_j = j;

multiplier MUL(
    .input_a(a_in),
    .input_b(b_in),
    .input_a_stb(mul_input_a_stb),
    .input_b_stb(mul_input_b_stb),
    .output_z_ack(mul_result_ack),
    .clk(clk),
    .rst(reset),
    .output_z(mul_result),
    .output_z_stb(mul_result_stb),
    .input_a_ack(mul_input_a_ack),
    .input_b_ack(mul_input_b_ack)
    );
    
adder ADDR(
    .input_a(mul_result),
    .input_b(z_out),
    .input_a_stb(mul_result_stb),
    .input_b_stb(add_input_b_stb),
    .output_z_ack(add_output_z_ack),
    .clk(clk),
    .rst(reset),
    .output_z(add_result),
    .output_z_stb(add_output_z_stb),
    .input_a_ack(mul_result_ack),
    .input_b_ack(add_input_b_ack)
);


always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= s_idle;
        done <= 0;
        i <= 0;
        j <= 0;
        k <= 0;
        z_out <= current_element;
        mul_output_z_ack <= 0;
        add_output_z_ack <= 0;
        add_input_a_stb <= 0;
        add_input_b_stb <= 0;
        mul_input_a_stb <= 0;
        mul_input_b_stb <= 0;
        reset <= 1;
    end
    else begin
        case (state)
            s_idle: begin
                if (start) begin
                    state <= s_reset;
                    done <= 0;
                    i <= 0;
                    j <= 0;
                    k <= 0;
                    z_out <= current_element;
                    reset <= 1;
                    mul_output_z_ack <= 0;
                    add_output_z_ack <= 0;
                    add_input_a_stb <= 0;
                    add_input_b_stb <= 0;
                    mul_input_a_stb <= 0;
                    mul_input_b_stb <= 0;
                end
            end
            s_reset: begin
                reset <= 0;
                state <= s_a_ack_mul;
                z_out <= current_element;
            end
            s_a_ack_mul: begin
                mul_input_a_stb <= 1;
                if (mul_input_a_ack) begin
                    mul_input_a_stb <= 0;
                    state <= s_b_ack_mul;
                end
            end
            s_b_ack_mul: begin
                mul_input_b_stb <= 1;
                if (mul_input_b_ack) begin
                    mul_input_b_stb <= 0;
                    state <= s_wait_mul;
                end
            end
            s_wait_mul: begin
                // when received -> go to wait add
                if (mul_result_ack) begin
                    state <= s_b_ack_add;
                    add_input_b_stb <= 1;
                end
            end

            s_b_ack_add: begin   
                if(add_input_b_ack) begin
                    add_input_b_stb <= 0;
                    state <= s_wait_add;     
                end
            end 
            s_wait_add: begin
                // when received -> go to calc
                if (add_output_z_stb) begin
                    z_out <= add_result;
                    add_output_z_ack <= 1;
                    z_stb <= 1;
                end
                if (z_ack) begin
                    z_stb <= 0;
                    reset <= 1;
                    state <= s_reset;

                    if (k >= m - 1) begin
                        z_out <= 0;
                        k <= 0;

                        if (j >= m - 1) begin
                            j <= 0;

                            if (i >= m - 1)
                                state <= s_done;
                            else
                                $display("\t i -> %d", i);
                                i <= i + 1;
                        end
                        else
                            $display("\t j -> %d", j);
                            j <= j + 1;
                    end
                    else 
                        $display("\t k -> %d", k);
                        k <= k + 1;
                end
            end
            s_done : begin
                done <= 1;
                state <= s_idle;
                $display("all done!");
            end
            default: state <= s_idle;
        endcase
    end
end

initial begin
    $monitor("state: %d, z_out: %b, mul_result: %b, add_result: %b, a_in: %b, b_in: %b", state, z_out, mul_result, add_result, a_in, b_in);
end

endmodule
