module byte_extractor (
    input        clk,
    input        rst,
    input        vld,
    input        sof,
    input        data[31:0],
    input        eof,
    output reg   ack,
    output reg   field,
    output reg   field_vld
);

    localparam BEAT_COUNTER_WIDTH = 4;
    reg [BEAT_COUNTER_WIDTH-1:0] beat_cnt;
    reg [4:0] temp_extracted_field;
    wire field_valid;

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            beat_cnt <= 0;
            temp_extracted_field <= 0;
            field_valid <= 0;
            field <= 0;
        end else {
            case (state)
                0: // IDLE
                    if (sof && vld) begin
                        beat_cnt <= 0;
                        state <= 1;
                    end else if (vld) begin
                        beat_cnt <= beat_cnt + 1;
                        state <= 1;
                    end else begin
                        state <= 0;
                    end
                end else if (state == 1) // EXTRACTING
                    if (beat_cnt == 1) begin
                        temp_extracted_field <= data[31:16];
                        state <= 2;
                    end else begin
                        state <= 1;
                    end
                end else if (state == 2) // DONE
                    field <= temp_extracted_field;
                    field_vld <= 1;
                    state <= 3;
                end else if (state == 3) // FAIL_FINAL
                    field_vld <= 0;
                    state <= 0;
            endcase
        }
    end

endmodule
