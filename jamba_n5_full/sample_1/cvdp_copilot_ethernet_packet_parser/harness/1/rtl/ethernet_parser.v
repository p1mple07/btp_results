module ether_parser (
    input wire clk,
    input wire rst,
    input wire vld,
    input wire sof,
    input wire [31:0] data,
    input wire eof,
    output reg ack,
    output reg [15:0] field,
    output reg [1:0] field_vld
);

    localparam BEAT_COUNTER_MAX = 4;
    localparam BEAT_COUNTER_MIN = 0;
    localparam BEAT_COUNTER_OFFSET = 2;

    reg [3:0] beat_cnt;
    reg [1:0] state;
    reg temp_extracted_field;
    reg field_vld;

    always @(posedge clk or posedge rst) begin
        if (!rst) begin
            beat_cnt <= 0;
            state <= IDLE;
            field <= 0;
            field_vld <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (vld & sof) begin
                        beat_cnt <= 1;
                        state <= EXTRACTING;
                    end else
                        state <= IDLE;
                end
                EXTRACTING: begin
                    if (beat_cnt == 1) begin
                        temp_extracted_field <= data[31:16];
                        state <= DONE;
                    end else
                        state <= EXTRACTING;
                end
                DONE: begin
                    ack <= 1;
                    field <= temp_extracted_field;
                    field_vld <= 1;
                end
                FAIL_FINAL: begin
                    ack <= 1;
                    field <= 0;
                    field_vld <= 0;
                    beat_cnt <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (beat_cnt >= BEAT_COUNTER_MAX) begin
            beat_cnt <= 0;
        end
    end

endmodule
