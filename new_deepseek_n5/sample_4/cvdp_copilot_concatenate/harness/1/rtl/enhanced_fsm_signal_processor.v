module enhanced_fsm_signal_processor (
    input clock,
    input rst_n,
    input enable,
    input clear,
    input acknowledge,
    input vector_1,
    input vector_2,
    input vector_3,
    input vector_4,
    input vector_5,
    input vector_6,
    output reg fsm_state,
    output reg o_ready,
    output reg o_error,
    output reg [1:0] o_fsm_status,
    output reg vector_1,
    output reg vector_2,
    output reg vector_3,
    output reg vector_4
);

    reg fsm_state = 00;
    reg [30:0] process_bus = 0;
    reg [7:0] state_reg;

    always @posedge clock begin
        if (rst_n) begin
            fsm_state = 00;
            state_reg = 0;
            o_ready = 0;
            o_error = 0;
            o_fsm_status = 00;
            vector_1 = 0;
            vector_2 = 0;
            vector_3 = 0;
            vector_4 = 0;
            return;
        end

        case (fsm_state)
        00: begin
            if (enable) begin
                fsm_state = 01;
                state_reg = 0;
            end
        end

        01: begin
            process_bus = vector_1 << 25 | vector_2 << 20 | vector_3 << 15 | vector_4 << 10 | (8'h1 << 9) | (8'h1 << 4);
            state_reg = 1;
            fsm_state = 10;
        end

        10: begin
            if (acknowledge) begin
                fsm_state = 00;
                state_reg = 0;
            end
        end

        11: begin
            if (clear) begin
                fsm_state = 00;
                state_reg = 0;
                o_error = 1;
            end
        end
    end

    // State encoding
    fsm_state = {state_reg[1], state_reg[0]};

    // Output vector mapping
    vector_1 = process_bus[30:24];
    vector_2 = process_bus[19:15];
    vector_3 = process_bus[14:10];
    vector_4 = process_bus[9:5];