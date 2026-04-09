module enhanced_fsm_signal_processor (
    input clock,
    input rst_n,
    input enable,
    input clear,
    input ack,
    input [4:0] vector_1,
    input [4:0] vector_2,
    input [4:0] vector_3,
    input [4:0] vector_4,
    input [4:0] vector_5,
    input [4:0] vector_6,
    output reg [1:0] fsm_status,
    output reg ready,
    output reg error,
    output [7:0] vector_1,
    output [7:0] vector_2,
    output [7:0] vector_3,
    output [7:0] vector_4,
    output [7:0] vector_5,
    output [7:0] vector_6
);

    reg [30:0] concatenated;
    reg [31:0] temp;
    reg [7:0] vector_1_out,
    reg [7:0] vector_2_out,
    reg [7:0] vector_3_out,
    reg [7:0] vector_4_out,
    reg [7:0] vector_5_out,
    reg [7:0] vector_6_out;

    always @posedge clock begin
        if (rst_n) begin
            fsm_status = 0b00;
            ready = 0;
            error = 0;
            vector_1_out = 0;
            vector_2_out = 0;
            vector_3_out = 0;
            vector_4_out = 0;
            vector_5_out = 0;
            vector_6_out = 0;
            next_state = 0b00;
        elsif (enable) begin
            if (fsm_status == 0b00) begin
                fsm_status = 0b01;
                next_state = 0b01;
            end else if (fsm_status == 0b01) begin
                concatenated = vector_1 << 25 | vector_2 << 20 | vector_3 << 15 | vector_4 << 10 | vector_5 << 5 | vector_6;
                temp = (concatenated) + (1 << 30 | 1 << 29);
                vector_1_out = (temp >> 24) & 0xFF;
                vector_2_out = (temp >> 19) & 0xFF;
                vector_3_out = (temp >> 14) & 0xFF;
                vector_4_out = (temp >> 9) & 0xFF;
                vector_5_out = (temp >> 4) & 0xFF;
                vector_6_out = temp & 0xFF;
                fsm_status = 0b01;
            end else if (fsm_status == 0b10) begin
                if (ack) begin
                    fsm_status = 0b00;
                    next_state = 0b00;
                end
            end else if (fsm_status == 0b11) begin
                error = 1;
                fsm_status = 0b00;
                next_state = 0b00;
            end
        end else begin
            next_state = fsm_status;
        end
    end

    always @posedge clock begin
        case (fsm_status)
            0b00: begin
                if (clear) begin
                    fsm_status = 0b00;
                    error = 0;
                    vector_1_out = 0;
                    vector_2_out = 0;
                    vector_3_out = 0;
                    vector_4_out = 0;
                    vector_5_out = 0;
                    vector_6_out = 0;
                end
            0b01: begin
                if (i_fault) begin
                    fsm_status = 0b11;
                    error = 0;
                    vector_1_out = 0;
                    vector_2_out = 0;
                    vector_3_out = 0;
                    vector_4_out = 0;
                    vector_5_out = 0;
                    vector_6_out = 0;
                end
            0b10: begin
                if (ack) begin
                    fsm_status = 0b00;
                end
            0b11: begin
                if (clear && !i_fault) begin
                    fsm_status = 0b00;
                end
            end
        end
    end

    fsm_status = next_state;
endmodule