module enhanced_fsm_signal_processor(
    input i_clk,
    input i_rst_n,
    input wire i_enable,
    input wire i_clear,
    input wire i_ack,
    input wire i_fault,
    input wire [4:0] i_vector_1,
    input wire [4:0] i_vector_2,
    input wire [4:0] i_vector_3,
    input wire [4:0] i_vector_4,
    input wire [4:0] i_vector_5,
    input wire [4:0] i_vector_6,
    output reg o_ready,
    output reg o_error,
    output reg [1:0] o_fsm_status,
    output reg [7:0] o_vector_1,
    output reg [7:0] o_vector_2,
    output reg [7:0] o_vector_3,
    output reg [7:0] o_vector_4
);

always_ff @(posedge i_clk) begin
    if (!i_rst_n) begin
        o_ready <= 0;
        o_error <= 0;
        o_fsm_status <= 2'b00;
        o_vector_1 <= 0;
        o_vector_2 <= 0;
        o_vector_3 <= 0;
        o_vector_4 <= 0;
    end else begin
        case (o_fsm_status) is
            2'b00: // IDLE
                if (i_enable) begin
                    o_fsm_status <= 2'b01;
                end else begin
                    o_ready <= 1;
                    o_error <= 0;
                    o_fsm_status <= 2'b00;
                end
        endcase
        case (o_fsm_status) is
            2'b01: // PROCESS
                if (i_clear) begin
                    // Clear outputs and reset fault
                    o_vector_1 <= 0;
                    o_vector_2 <= 0;
                    o_vector_3 <= 0;
                    o_vector_4 <= 0;
                    o_ready <= 1;
                    o_error <= 0;
                    o_fsm_status <= 2'b10;
                end else if (i_ack) begin
                    o_ready <= 1;
                    o_error <= 0;
                    o_fsm_status <= 2'b00;
                end else begin
                    // Stay in PROCESS
                end
        endcase
        case (o_fsm_status) is
            2'b10: // READY
                if (i_ack) begin
                    o_ready <= 1;
                    o_error <= 0;
                    o_fsm_status <= 2'b00;
                end else begin
                    o_ready <= 0;
                    o_error <= 0;
                    o_fsm_status <= 2'b00;
                end
        endcase
        case (o_fsm_status) is
            2'b11: // FAULT
                o_error <= 1;
                o_fsm_status <= 2'b00;
                // No changes
        endcase
    end
end

endmodule
