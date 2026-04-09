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

    // Internal registers
    reg [DATA_WIDTH-1:0] a_reg, b_reg, sum_reg;
    reg [1:0] status;

    // State register
    reg [2:0] state_reg;

    // Combinational logic for mode determination
    always @(posedge i_enable) begin
        if (i_enable) begin
            if (i_mode == 0)
                state_reg <= 2'b00; // IDLE
            else if (i_mode == 1)
                state_reg <= 2'b01; // LOAD
        end else
            state_reg <= 2'b00; // Reset state on deassertion
    end

    // State machine logic
    always @(posedge i_clk or i_rst_n) begin
        if (i_rst_n) begin
            status <= 2'b00; // Reset to IDLE
            a_reg <= 0;
            b_reg <= 0;
            sum_reg <= 0;
        end else begin
            case (state_reg)
                2'b00: begin
                    if (i_start) begin
                        status <= 2'b01; // Load state
                        a_reg <= i_operand_a;
                        b_reg <= i_operand_b;
                    end
                end
                2'b01: begin
                    sum_reg <= a_reg + b_reg;
                    if (i_clear) begin
                        status <= 2'b00; // Reset to IDLE
                        a_reg <= 0;
                        b_reg <= 0;
                        sum_reg <= 0;
                    end
                end
                2'b10: begin
                    o_resultant_sum <= sum_reg;
                    o_overflow <= (sum_reg[DATA_WIDTH-1] & (a_reg[DATA_WIDTH-1] ^ b_reg[DATA_WIDTH-1]));
                    o_ready <= 1'b1;
                    status <= 2'b11; // Output state
                end
            end
        end
    end

endmodule
