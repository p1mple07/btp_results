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
    output [2:0] o_fsm_status
);

    // State declaration
    reg [2:0] state_reg;
    reg [31:0] concatenated_vector;
    wire [7:0] o_vector_1_out, o_vector_2_out, o_vector_3_out, o_vector_4_out;

    // State transition logic
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            state_reg <= 3'b000;
            o_vector_1_out <= 8'b0;
            o_vector_2_out <= 8'b0;
            o_vector_3_out <= 8'b0;
            o_vector_4_out <= 8'b0;
            o_error <= 0;
            o_fsm_status <= 3'b000;
        end else begin
            case (state_reg)
                3'b000: begin
                    if (!i_enable) begin
                        state_reg <= 3'b000;
                    end else if (i_fault) begin
                        state_reg <= 3'b111;
                    end else begin
                        state_reg <= 3'b001;
                    end
                end
                3'b001: begin
                    concatenated_vector <= i_vector_1 << 28 | i_vector_2 << 23 | i_vector_3 << 18 | i_vector_4 << 13 | i_vector_5 << 8 | i_vector_6 << 3;
                    o_vector_1_out <= concatenated_vector[27:20];
                    o_vector_2_out <= concatenated_vector[26:21];
                    o_vector_3_out <= concatenated_vector[25:21];
                    o_vector_4_out <= concatenated_vector[24:21];
                    state_reg <= 3'b010;
                end
                3'b010: begin
                    if (i_ack) begin
                        state_reg <= 3'b000;
                    end else if (i_fault) begin
                        state_reg <= 3'b111;
                    end else begin
                        state_reg <= 3'b010;
                    end
                end
                3'b111: begin
                    o_error <= 1;
                    o_vector_1_out <= 8'b0;
                    o_vector_2_out <= 8'b0;
                    o_vector_3_out <= 8'b0;
                    o_vector_4_out <= 8'b0;
                    state_reg <= 3'b000;
                end
            endcase
        end
    end

    // Output logic
    assign o_ready = (state_reg == 3'b010);
    assign o_vector_1 = o_vector_1_out;
    assign o_vector_2 = o_vector_2_out;
    assign o_vector_3 = o_vector_3_out;
    assign o_vector_4 = o_vector_4_out;

endmodule
