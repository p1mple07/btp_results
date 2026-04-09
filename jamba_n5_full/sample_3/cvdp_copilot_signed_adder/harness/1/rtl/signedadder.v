module signedadder #(parameter DATA_WIDTH = 8) (
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

    localparam NUM_STATES = 4;
    reg [NUM_STATES-1:0] current_state;
    reg next_state;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n) begin
            current_state <= 0;
            o_resultant_sum <= 0;
            o_overflow <= 0;
            o_ready <= 1;
            o_status <= 3; // IDLE
            return;
        end else begin
            next_state = current_state;
            case (current_state)
                0: // IDLE
                    if (i_start) begin
                        next_state = 1; // LOAD
                    end else begin
                        next_state = 0;
                    end
                // other states
            endcase
        end
    end

    always_comb begin
        case (current_state)
            1: // LOAD
                // capture inputs
                o_resultant_sum <= i_operand_a;
                o_overflow <= 0;
                o_ready <= 0;
                o_status <= 0;
            // maybe reset inside
        endcase
    end

endmodule
