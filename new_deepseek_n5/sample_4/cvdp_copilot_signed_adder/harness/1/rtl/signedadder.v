module signedadder #(parameter DATA_WIDTH = 8)(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);
    reg [1:0] current_state;
    reg [DATA_WIDTH-1:0] a, b;
    reg [DATA_WIDTH-1:0] sum;
    reg overflow;

    always @* begin
        if (i_rst_n) begin
            current_state = 0b00;
            a = 0;
            b = 0;
            o_resultant_sum = 0;
            o_overflow = 0;
            o_ready = 0;
        end else begin
            if (i_start && i_enable) begin
                current_state = 0b01;
                a = i_operand_a;
                b = i_operand_b;
                o_resultant_sum = 0;
                o_overflow = 0;
                o_ready = 0;
            end else if (i_mode) begin
                current_state = 0b10;
                sum = a - b;
                o_resultant_sum = sum;
                o_overflow = 0;
                o_ready = 0;
            end else if (i_clear) begin
                current_state = 0b11;
                o_resultant_sum = 0;
                o_overflow = 0;
                o_ready = 0;
            end else begin
                current_state = 0b00;
            end
        end
    end

    // Overflow detection logic
    always @* begin
        if (current_state == 0b10) begin
            if (((a & b) & (o_resultant_sum ^ a)) || ((~a & ~b) & o_resultant_sum)) begin
                o_overflow = 1;
            end
        end
    end

    // Ready output
    always @* begin
        if (current_state == 0b11) begin
            o_ready = 1;
        end
    end
endmodule