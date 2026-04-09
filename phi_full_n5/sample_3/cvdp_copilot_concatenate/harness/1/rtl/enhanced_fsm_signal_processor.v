module enhanced_fsm_signal_processor(
    input i_clk,
    input i_rst_n,
    input i_enable,
    input i_clear,
    input i_ack,
    input i_fault,
    input [5:0] i_vector_1,
    input [5:0] i_vector_2,
    input [5:0] i_vector_3,
    input [5:0] i_vector_4,
    input [5:0] i_vector_5,
    input [5:0] i_vector_6,
    output reg o_ready,
    output reg o_error,
    output reg [2:0] o_fsm_status,
    output [7:0] o_vector_1,
    output [7:0] o_vector_2,
    output [7:0] o_vector_3,
    output [7:0] o_vector_4
);

    // Internal signals
    reg [31:0] concatenated_bus;
    reg [7:0] o_vector_1_out, o_vector_2_out, o_vector_3_out, o_vector_4_out;

    // State register
    reg [2:0] state_reg, next_state;

    // Reset logic
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            state_reg <= 3'b000;
            o_vector_1_out <= 0;
            o_vector_2_out <= 0;
            o_vector_3_out <= 0;
            o_vector_4_out <= 0;
            o_ready <= 0;
            o_error <= 0;
        end else begin
            if (i_enable) begin
                state_reg <= state_reg + 1;
            end
        end
    end

    // Next state logic
    always @(posedge i_clk) begin
        next_state = state_reg;
        case (next_state)
            3'b000: begin
                if (i_fault) begin
                    state_reg <= 3'b111;
                    o_error <= 1;
                end else begin
                    state_reg <= 3'b000;
                end
            end
            3'b001: begin
                concatenated_bus <= (i_vector_1 << 31) | (i_vector_2 << 26) | (i_vector_3 << 21) | (i_vector_4 << 16) | (i_vector_5 << 11) | (i_vector_6 << 6) | 3'b11;
                o_vector_1_out <= concatenated_bus[7:0];
                o_vector_2_out <= concatenated_bus[15:8];
                o_vector_3_out <= concatenated_bus[23:16];
                o_vector_4_out <= concatenated_bus[31:24];
                o_ready <= 1;
                o_fsm_status <= 3'b10;
            end
            3'b010: begin
                if (i_fault) begin
                    state_reg <= 3'b111;
                    o_error <= 1;
                end else begin
                    state_reg <= 3'b000;
                end
            end
            3'b011: begin
                if (i_clear) begin
                    state_reg <= 3'b000;
                end else begin
                    state_reg <= 3'b011;
                end
            end
        end
    end

    // Output logic
    assign o_vector_1 = o_vector_1_out;
    assign o_vector_2 = o_vector_2_out;
    assign o_vector_3 = o_vector_3_out;
    assign o_vector_4 = o_vector_4_out;

endmodule
