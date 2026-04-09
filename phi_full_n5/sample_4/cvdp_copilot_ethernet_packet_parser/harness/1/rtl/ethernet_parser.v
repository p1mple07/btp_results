module ethernet_parser (
    input clk,
    input rst,
    input vld,
    input sof,
    input [31:0] data,
    input eof,
    output reg ack,
    output [15:0] field,
    output reg field_vld
);

    reg [3:0] beat_cnt;
    reg [15:0] temp_extracted_field;
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            beat_cnt <= 0;
            field <= 0;
            temp_extracted_field <= 0;
            field_vld <= 0;
            state <= 0;
        end else begin
            case (state)
                0: begin
                    if (vld && sof) begin
                        beat_cnt <= 0;
                        field <= 0;
                        temp_extracted_field <= 0;
                        field_vld <= 0;
                        state <= 1;
                    end
                end
                1: begin
                    if (vld) begin
                        beat_cnt <= beat_cnt + 1;
                        if (beat_cnt == 1) begin
                            temp_extracted_field <= data[31:16];
                            field_vld <= 1;
                        end
                    end
                    if (eof) begin
                        state <= 2;
                    end
                end
                2: begin
                    field <= temp_extracted_field;
                    field_vld <= 0;
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
