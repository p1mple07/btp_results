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

    reg [3:0] beat_cnt;
    reg [15:0] temp_extracted_field;
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            beat_cnt <= 0;
            field <= 16'h0000;
            field_vld <= 0;
            state <= 0;
        end else begin
            case (state)
                0: begin
                    if (vld && sof) begin
                        state <= 1;
                    end
                    else state <= 0;
                end
                1: begin
                    if (beat_cnt == 1) begin
                        temp_extracted_field <= data[31:16];
                        state <= 2;
                    end else begin
                        beat_cnt <= beat_cnt + 1;
                        state <= 1;
                    end
                end
                2: begin
                    field <= temp_extracted_field;
                    field_vld <= 1;
                    state <= 0;
                end
                3: begin
                    field_vld <= 0;
                    state <= 0;
                end
            endcase
        end
    end

    assign ack = 1'b1;

endmodule
