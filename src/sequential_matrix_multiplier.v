module sequential_matrix_multiplier
#(
    parameter m = 4
)
(
    input                           clk,
    input                           rst,
    input                           start,
    input   [31:0]                  a_in,
    input   [31:0]                  b_in,
    input                           z_ack;
    output  [$ceil($clog2(m))-1:0]  a_i,
    output  [$ceil($clog2(m))-1:0]  a_j,
    output  [$ceil($clog2(m))-1:0]  b_i,
    output  [$ceil($clog2(m))-1:0]  b_j,
    output  reg [31:0]              z_out,
    output  [$ceil($clog2(m))-1:0]  z_i,
    output  [$ceil($clog2(m))-1:0]  z_j,
    output                          z_stb,
    output  reg                     done
);

localparam s_idle       =       3'b000;
localparam s_calc       =       3'b001;
localparam s_wait_mul   =       3'b010;
localparam s_wait_add   =       3'b011; 
localparam s_done       =       3'b100;

localparam m_len = $ceil($clog2(m));


reg [1:0]       state;
reg [m_len-1:0] i;
reg [m_len-1:0] j;
reg [m_len-1:0] k;

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
    .output_z_ack(mul_output_z_ack),
    .clk(clk),
    .rst(rst),
    .output_z(mul_result),
    .output_z_stb(mul_output_z_stb),
    .input_a_ack(mul_input_a_ack),
    .input_b_ack(mul_input_b_ack)
    );
    
adder ADDR(
    .input_a(z_out),
    .input_b(mul_result),
    .input_a_stb(add_input_a_stb),
    .input_b_stb(add_input_b_stb),
    .output_z_ack(add_output_z_ack),
    .clk(clk),
    .rst(rst),
    .output_z(add_result),
    .output_z_stb(add_output_z_stb),
    .input_a_ack(add_input_a_ack),
    .input_b_ack(add_input_b_ack)
);



always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state <= idle;
        done <= 0;
        i <= 0;
        j <= 0;
        k <= 0;
        z_out <= 0;
    end
    else begin
        case (state)
            s_idle : begin
                if (start) begin
                    state <= s_calc;
                    done <= 0;
                    i <= 0;
                    j <= 0;
                    k <= 0;
                    z_out <= 0;
                end
            end
            s_calc : begin
                mul_input_a_stb <= 1;
                mul_input_b_stb <= 1;
                // wait until inputs are acknowledged
                if (mul_input_a_ack && mul_input_b_ack) begin
                    mul_input_a_stb <= 0;
                    mul_input_b_stb <= 0;
                    state <= s_wait_mul;
                end
            end
            s_wait_mul: begin
                // when received -> go to wait add
                if (mul_output_z_stb) begin
                    add_input_a_stb <= 1;
                    add_input_b_stb <= 1;
                end
                if (add_input_a_ack && add_input_b_ack) begin
                    mul_output_z_ack <= 1;
                    add_input_a_stb <= 0;
                    add_input_b_stb <= 0;
                    state <= s_wait_add;
                end
            end
            s_wait_add: begin
                // when received -> go to calc
                if (add_output_z_stb) begin
                    z_out <= add_result;
                    z_stb <= 1;
                end
                if (z_ack) begin
                    z_stb <= 0;
                    add_output_z_ack <= 1;
                    state <= s_calc;

                    if (k == m - 1) begin
                        z_out <= 0;
                        k <= 0;

                        if (j == m - 1) begin
                            j <= 0;

                            if (i == m - 1)
                                state <= s_done;
                            else
                                i <= i + 1;
                        end
                        else
                            j <= j + 1;
                    end
                    else 
                        k <= k + 1;
                end
            end
            s_done : begin
                done <= 1;
                state <= idle;
            end
            default: state <= s_idle;
        endcase
    end
end

endmodule
