module rtl/ethernet_parser (
    input clock,
    input rst,
    input [31:0] data,
    input vld,
    input sof,
    input eof,
    output ack,
    output [15:0] field,
    output field_vld
);

    // State control
    reg state = IDLE;
    reg [3:0] beat_cnt = 0;

    // Temporary storage
    reg [15:0] temp_extracted_field = 0;

    // State transitions
    always @posedge clock begin
        case (state)
            IDLE:
                if (vld && sof) begin
                    state = EXTRACTING;
                    beat_cnt = 0;
                    field_vld = 0;
                end
                // else: stay in IDLE
            EXTRACTING:
                if (vld) begin
                    beat_cnt = beat_cnt + 1;
                    if (beat_cnt == 1) begin
                        temp_extracted_field = data[31:16];
                        field = temp_extracted_field;
                        field_vld = 1;
                        state = DONE;
                    end
                end
            DONE:
                if (eof) begin
                    field_vld = 0;
                    state = FAIL_FINAL;
                end
            FAIL_FINAL:
                if (eof) begin
                    field_vld = 0;
                    state = IDLE;
                end
                // else: stay in FAIL_FINAL
        default:
            // Handle unexpected transitions
            state = IDLE;
        endcase
    end

    // Acknowledge signal is always high
    ack = 1;

endmodule