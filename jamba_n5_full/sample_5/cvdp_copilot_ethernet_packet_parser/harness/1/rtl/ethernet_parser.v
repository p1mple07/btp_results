module byte_extractor (
    input wire clk,
    input wire rst,
    input wire [3:0] vld,
    input wire [3:0] sof,
    input wire [31:0] data,
    input wire eof,
    output reg ack,
    output reg [15:0] field,
    output reg [1:0] field_vld
);

reg beat_cnt;
reg temp_extracted_field;
reg [3:0] state;

initial begin
    beat_cnt = 0;
    temp_extracted_field = 0;
    state = 0;
    ack = 1;
end

always @(posedge clk or negedge rst) begin
    if (rst) begin
        beat_cnt <= 0;
        temp_extracted_field = 0;
        state = 0;
    end else begin
        case (state)
            IDLE: begin
                if (sof && vld) begin
                    beat_cnt <= 0;
                    state <= EXTRACTING;
                end
            end
            EXTRACTING: begin
                if (beat_cnt == 1) begin
                    temp_extracted_field <= data[31:16];
                end else if (beat_cnt == 0) begin
                    beat_cnt <= 1;
                    state <= EXTRACTING;
                end else begin
                    beat_cnt <= 0;
                    state <= IDLE;
                end
            end
            DONE: begin
                field <= temp_extracted_field;
                field_vld <= 1;
            end
            FAIL_FINAL: begin
                field_vld <= 0;
                state <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    assign ack = 1;
end

endmodule
