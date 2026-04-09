module ethernet_parser (
    input clk,
    input rst,
    input vld,
    input sof,
    input [31:0] data,
    input eof,
    output reg ack,
    output reg [15:0] field,
    output reg field_vld
);

    // Internal signals
    reg [3:0] beat_cnt;
    reg [15:0] temp_extracted_field;
    reg [1:0] state = 0;

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            beat_cnt <= 0;
            temp_extracted_field <= 16'b0;
            field <= 16'b0;
            field_vld <= 0;
            state <= 0;
        end else if (beat_cnt == 1) begin
            state <= 1;
        end else if (state == 1) begin
            temp_extracted_field <= data[31:16];
            state <= 2;
        end else if (state == 2) begin
            field <= temp_extracted_field;
            field_vld <= 1;
            state <= 3;
        end else if (state == 3) begin
            field_vld <= 0;
            state <= 0;
        end
    end

    // Acknowledge signal
    always @(posedge clk) begin
        ack <= 1;
    end

    // Validation signal
    always @(posedge clk) begin
        if (state == 2) begin
            field_vld <= 1;
        end else begin
            field_vld <= 0;
        end
    end

endmodule
