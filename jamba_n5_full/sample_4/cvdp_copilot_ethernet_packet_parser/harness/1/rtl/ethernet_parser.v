module rtl_extractor (
    input clk,
    input rst,
    input vld,
    input soff,
    input [31:0] data,
    input eof,
    output reg ack,
    output reg [15:0] field,
    output reg field_vld
);

    // Internal signals
    wire beat_cnt;
    wire temp_extracted_field;
    state machine state;

    always @(posedge clk or negedge rst) begin
        if (rst) begin
            beat_cnt <= 0;
            temp_extracted_field <= 0;
            field_vld <= 1'b0;
            ack <= 1'b1;
        end else begin
            state <= case (state)
                IDLE: IF (vld & soff) begin
                    beat_cnt <= 0;
                    temp_extracted_field <= 0;
                    field_vld <= 1'b0;
                end else begin
                    state = EXTRACTING;
                end
                EXTRACTING: IF (beat_cnt == 1) begin
                    temp_extracted_field <= data[31:16];
                    beat_cnt <= 0;
                    field_vld <= 1'b1;
                end else begin
                    state = DONE;
                end
                DONE: begin
                    field <= temp_extracted_field;
                    field_vld <= 1'b1;
                end
                FAIL_FINAL: begin
                    field_vld <= 1'b0;
                    ack <= 1'b1;
                end
            endcase
        end
    end

endmodule
