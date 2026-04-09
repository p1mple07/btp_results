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

    // Internal signals
    reg [DATA_WIDTH-1:0] a_reg, b_reg;
    reg [1:0] state, next_state;

    // State encoding
    localparam IDLE = 2'b00, LOAD = 2'b01, COMPUTE = 2'b10, OUTPUT = 2'b11;

    // State transition logic
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            state <= IDLE;
            a_reg <= 0;
            b_reg <= 0;
            o_overflow <= 0;
            o_resultant_sum <= 0;
            o_ready <= 0;
        end else if (i_start && i_enable) begin
            state <= IDLE;
        end else if (state == IDLE && i_start && i_enable) begin
            state <= LOAD;
        end else if (state == LOAD) begin
            a_reg <= i_operand_a;
            b_reg <= i_operand_b;
            state <= COMPUTE;
        end else if (state == COMPUTE) begin
            case (i_mode)
                2'b0: o_resultant_sum <= a_reg + b_reg;
                2'b1: o_resultant_sum <= a_reg - b_reg;
                default: o_resultant_sum <= 0;
            endcase
            // Overflow detection
            if ((i_mode == 2'b0 && (a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1]) != 0) ||
                (i_mode == 2'b1 && (!(a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1]))) ||
                (a_reg[DATA_WIDTH-1] == b_reg[DATA_WIDTH-1] && a_reg[DATA_WIDTH-2:0] < b_reg[DATA_WIDTH-2:0]))
                o_overflow <= 1;
            else
                o_overflow <= 0;
            state <= OUTPUT;
        end
    end

    // Output logic
    always @(state) begin
        case (state)
            IDLE: o_status <= IDLE;
            LOAD: o_status <= LOAD;
            COMPUTE: o_status <= COMPUTE;
            OUTPUT: o_status <= OUTPUT;
            default: o_status <= IDLE;
        endcase
    end

    // Outputs
    always @(state or o_resultant_sum or o_overflow) begin
        case (state)
            IDLE: o_ready <= 0;
            LOAD: o_ready <= 0;
            COMPUTE: o_ready <= 1;
            OUTPUT: o_ready <= 1;
            default: o_ready <= 0;
        endcase
    end

endmodule
