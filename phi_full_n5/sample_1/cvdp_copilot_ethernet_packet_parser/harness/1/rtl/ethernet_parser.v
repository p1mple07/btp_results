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

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            beat_cnt <= 0;
            field <= 0;
            field_vld <= 0;
            state <= 0;
        end else begin
            case (state)
                0: begin
                    if (sof && vld) begin
                        beat_cnt <= 0;
                        field <= 0;
                        field_vld <= 0;
                        state <= 1;
                    end
                end
                1: begin
                    if (vld && beat_cnt == 1) begin
                        temp_extracted_field <= data[31:16];
                        state <= 2;
                    end
                end
                2: begin
                    field <= temp_extracted_field;
                    field_vld <= 1;
                    if (eof) begin
                        state <= 3;
                    end
                end
                3: begin
                    field_vld <= 0;
                    state <= 0;
                end
            endcase
        end
    end

    // Acknowledge signal always high
    always @(posedge clk) begin
        ack <= 1;
    end

endmodule
