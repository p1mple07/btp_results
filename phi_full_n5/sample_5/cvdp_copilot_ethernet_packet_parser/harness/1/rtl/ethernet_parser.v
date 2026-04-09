module ethernet_parser(
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
            temp_extracted_field <= 0;
            field <= 0;
            field_vld <= 0;
            state <= 0;
        end else if (sof && vld) begin
            beat_cnt <= 0;
            state <= 1; // EXTRACTING
        end else if (beat_cnt == 1) begin
            temp_extracted_field <= data[31:16];
            state <= 2; // DONE
        end else if (beat_cnt == 3) begin
            field <= temp_extracted_field;
            field_vld <= 1;
            state <= 0; // IDLE
        end
    end

    always @(state) begin
        case (state)
            0: begin
                if (sof && vld) begin
                    beat_cnt <= 0;
                    temp_extracted_field <= 0;
                    field <= 0;
                    field_vld <= 0;
                    state <= 1; // EXTRACTING
                end
            end
            1: begin
                if (vld) begin
                    beat_cnt <= beat_cnt + 1;
                end else begin
                    state <= 0; // IDLE
                end
            end
            2: begin
                field <= temp_extracted_field;
                field_vld <= 1;
                state <= 0; // IDLE
            end
            3: begin
                field_vld <= 0;
                state <= 0; // IDLE
            end
            default: state <= 0; // IDLE
        endcase
    end

    assign ack = 1;

endmodule
