module enhanced_fsm_signal_processor (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_enable,
    input wire i_clear,
    input wire i_ack,
    input wire i_fault,
    input [5] i_vector_1,
    input [5] i_vector_2,
    input [5] i_vector_3,
    input [5] i_vector_4,
    input [5] i_vector_5,
    input [5] i_vector_6,
    output reg o_ready,
    output reg o_error,
    output reg [1] o_fsm_status,
    output [8] o_vector_1,
    output [8] o_vector_2,
    output [8] o_vector_3,
    output [8] o_vector_4
);

    // FSM states
    reg fsm_state = 0; // 0: IDLE, 1: PROCESS, 2: READY, 3: FAULT

    // State transition table
    always @* begin
        if (i_rst_n) begin
            fsm_state = 0;
            o_ready = 0;
            o_error = 0;
            o_fsm_status = 0b00;
        end else if (i_enable) begin
            fsm_state = 1;
        end else if (i_ack) begin
            fsm_state = 2;
        end else if (i_fault) begin
            fsm_state = 3;
        end
    end

    // Vector processing
    wire [31:0] process_bus = 0;
    always @* begin
        if (fsm_state == 1) begin
            process_bus = (i_vector_1 << 25) | (i_vector_2 << 20) | (i_vector_3 << 15) | (i_vector_4 << 10) | (i_vector_5 << 5) | i_vector_6;
            process_bus = process_bus + 2;
            o_vector_1 = (process_bus >> 24) & 0xFF;
            o_vector_2 = (process_bus >> 19) & 0xFF;
            o_vector_3 = (process_bus >> 14) & 0xFF;
            o_vector_4 = (process_bus >> 9) & 0xFF;
        end else if (fsm_state == 3 && i_clear && !i_fault) begin
            o_vector_1 = 0;
            o_vector_2 = 0;
            o_vector_3 = 0;
            o_vector_4 = 0;
            fsm_state = 0;
        end
    end

    // State outputs
    always @* begin
        o_fsm_status = fsm_state;
    end

    // Error output
    always @* begin
        o_error = i_fault;
    end
endmodule