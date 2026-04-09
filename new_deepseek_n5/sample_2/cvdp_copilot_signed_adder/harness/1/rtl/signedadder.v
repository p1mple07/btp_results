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
    reg o_state; // State control
    reg [DATA_WIDTH-1:0] a, b; // Operand registers
    reg [DATA_WIDTH-1:0] sum; // Intermediate sum

    // Reset handling
    always @(i_rst_n) begin
        if (i_rst_n) begin
            o_state = 0; // IDLE state
            o_ready = 0;
            o_overflow = 0;
            a = 0;
            b = 0;
        end
    end

    // Load state
    always @(i_start, i_enable) begin
        if (i_enable && !i_rst_n && !o_state) begin
            a = i_operand_a;
            b = i_operand_b;
            o_state = 1; // LOAD state
        end
    end

    // Compute state
    always @(i_mode) begin
        if (o_state == 1) begin
            if (i_mode == 0) begin // Add
                sum = a + b;
            else begin // Subtract
                sum = a - b;
            end
            o_state = 2; // COMPUTE state
        end
    end

    // Output state
    always @(i_clk) begin
        if (o_state == 2) begin
            // Overflow detection
            reg sign_a, sign_b, sign_sum;
            sign_a = (a >> (DATA_WIDTH-1)) & 1;
            sign_b = (b >> (DATA_WIDTH-1)) & 1;
            sign_sum = (sum >> (DATA_WIDTH-1)) & 1;

            o_overflow = 0;
            if ((sign_a & sign_b) != sign_sum) begin
                o_overflow = 1;
            end

            o_resultant_sum = sum;
            o_ready = 1;
            o_state = 3; // OUTPUT state
        end
    end

    // Clear operation
    always @(i_clear) begin
        if (i_clear) begin
            o_resultant_sum = 0;
            o_overflow = 0;
            o_ready = 0;
            o_state = 0; // IDLE state
        end
    end
endmodule