module rtl/ethernet_parser (
    input clock,
    input rst,
    input vld,
    input sof,
    input data,
    input eof,
    output ack,
    output field,
    output field_vld
);

    // State machine: 2-bit value (0: IDLE, 1: EXTRACTING, 2: DONE, 3: FAIL_FINAL)
    reg state = 0;
    reg beat_cnt = 0;
    reg field_valid = 0;
    reg temp_extracted_field = 0;

    // State transitions
    always clocked begin
        if (rst) begin
            state = 0;
            beat_cnt = 0;
            field_valid = 0;
            temp_extracted_field = 0;
            ack = 1;
        end else begin
            case (state)
                0: begin
                    if (vld && sof) begin
                        state = 1;
                        beat_cnt = 0;
                        field_valid = 0;
                    end
                end;
                1: begin
                    if (vld) begin
                        beat_cnt = beat_cnt + 1;
                        if (beat_cnt == 1) begin
                            field = data[31:16];
                            field_vld = 1;
                        end else if (beat_cnt == 15) begin
                            field_vld = 0;
                            state = 3;
                        end
                    end
                end;
                2: begin
                    field_vld = 1;
                end;
                3: begin
                    field_vld = 0;
                    state = 0;
                end
            end
        end
    end

    // Acknowledge signal
    ack = 1;

    // Field extraction output
    field = 0;
    field_vld = 0;
endmodule